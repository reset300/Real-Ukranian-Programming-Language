const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");
const Value = @import("value.zig").Value;

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: []const lexer.Token,
    current: usize = 0,
    last_error: ?lexer.Token = null,

    pub fn init(allocator: std.mem.Allocator, tokens: []const lexer.Token) Parser {
        return .{
            .allocator = allocator,
            .tokens = tokens,
        };
    }

    pub fn parseProgram(self: *Parser) anyerror![]ast.Stmt {
        var statements: std.ArrayList(ast.Stmt) = .empty;
        errdefer statements.deinit(self.allocator);

        self.skipNewlines();
        while (!self.check(.eof)) {
            try statements.append(self.allocator, try self.statement());
            self.skipNewlines();
        }

        return try statements.toOwnedSlice(self.allocator);
    }

    pub fn errorToken(self: *const Parser) ?lexer.Token {
        return self.last_error;
    }

    fn statement(self: *Parser) anyerror!ast.Stmt {
        if (self.match(.keyword_mutable)) return self.variableStatement();
        if (self.match(.keyword_print)) return self.printStatement();
        if (self.match(.keyword_if)) return self.ifStatement();
        if (self.match(.keyword_while)) return self.whileStatement();
        if (self.match(.keyword_for)) return self.forStatement();
        if (self.match(.keyword_switch)) return self.switchStatement();
        if (self.match(.keyword_function)) return self.functionStatement();
        if (self.match(.keyword_return)) return self.returnStatement();
        if (self.match(.keyword_break)) {
            try self.consumeLineEnd();
            return .break_stmt;
        }
        if (self.match(.keyword_continue)) {
            try self.consumeLineEnd();
            return .continue_stmt;
        }
        if (self.check(.identifier) and self.peekNextTag() == .keyword_becomes) {
            return self.assignmentStatement();
        }
        if (self.check(.identifier) and self.peekNextTag() == .keyword_became) {
            self.failHere();
            return error.BecameOnlyForDeclaration;
        }
        if (self.check(.keyword_call)) return self.expressionStatement();

        self.failHere();
        return error.ExpectedStatement;
    }

    fn variableStatement(self: *Parser) anyerror!ast.Stmt {
        const name = (try self.consume(.identifier, error.ExpectedVariableName)).lexeme;

        if (self.match(.keyword_becomes)) {
            self.last_error = self.previous();
            return error.DeclarationRequiresBecame;
        }

        _ = try self.consume(.keyword_became, error.ExpectedBecame);
        const value = try self.expression();
        try self.consumeLineEnd();

        return .{
            .variable = .{
                .name = name,
                .value = value,
            },
        };
    }

    fn assignmentStatement(self: *Parser) anyerror!ast.Stmt {
        const name = self.advance().lexeme;
        _ = try self.consume(.keyword_becomes, error.ExpectedBecomes);
        const value = try self.expression();
        try self.consumeLineEnd();

        return .{
            .assign = .{
                .name = name,
                .value = value,
            },
        };
    }

    fn printStatement(self: *Parser) anyerror!ast.Stmt {
        _ = try self.consume(.l_paren, error.ExpectedLeftParen);

        var arguments: std.ArrayList(*ast.Expr) = .empty;
        errdefer arguments.deinit(self.allocator);

        if (!self.check(.r_paren)) {
            while (true) {
                try arguments.append(self.allocator, try self.expression());
                if (!self.match(.comma)) break;
            }
        }

        _ = try self.consume(.r_paren, error.ExpectedRightParen);
        try self.consumeLineEnd();

        return .{
            .print = try arguments.toOwnedSlice(self.allocator),
        };
    }

    fn expressionStatement(self: *Parser) anyerror!ast.Stmt {
        const expr = try self.expression();
        try self.consumeLineEnd();
        return .{ .expression = expr };
    }

    fn ifStatement(self: *Parser) anyerror!ast.Stmt {
        const condition = try self.expression();
        const then_branch = try self.block();

        var elif_branches: std.ArrayList(ast.ElseIfBranch) = .empty;
        errdefer elif_branches.deinit(self.allocator);

        var else_branch: ?[]ast.Stmt = null;
        self.skipNewlines();

        while (self.match(.keyword_else)) {
            if (self.match(.keyword_if)) {
                const elif_condition = try self.expression();
                const elif_body = try self.block();
                try elif_branches.append(self.allocator, .{
                    .condition = elif_condition,
                    .body = elif_body,
                });
                self.skipNewlines();
            } else {
                else_branch = try self.block();
                break;
            }
        }

        return .{
            .if_stmt = .{
                .condition = condition,
                .then_branch = then_branch,
                .elif_branches = try elif_branches.toOwnedSlice(self.allocator),
                .else_branch = else_branch,
            },
        };
    }

    fn whileStatement(self: *Parser) anyerror!ast.Stmt {
        const condition = try self.expression();
        const body = try self.block();
        return .{
            .while_stmt = .{
                .condition = condition,
                .body = body,
            },
        };
    }

    fn forStatement(self: *Parser) anyerror!ast.Stmt {
        const name = (try self.consume(.identifier, error.ExpectedLoopVariable)).lexeme;
        _ = try self.consume(.keyword_from, error.ExpectedFrom);
        const start = try self.expression();
        _ = try self.consume(.keyword_to, error.ExpectedTo);
        const end = try self.expression();
        const body = try self.block();

        return .{
            .for_range = .{
                .name = name,
                .start = start,
                .end = end,
                .body = body,
            },
        };
    }

    fn switchStatement(self: *Parser) anyerror!ast.Stmt {
        const value = try self.expression();
        self.skipNewlines();
        _ = try self.consume(.keyword_begin, error.ExpectedBegin);
        self.skipNewlines();

        var cases: std.ArrayList(ast.SwitchCase) = .empty;
        errdefer cases.deinit(self.allocator);
        var default_branch: ?[]ast.Stmt = null;

        while (!self.check(.keyword_end) and !self.check(.eof)) {
            if (self.match(.keyword_case)) {
                const case_value = try self.expression();
                const case_body = try self.block();
                try cases.append(self.allocator, .{
                    .value = case_value,
                    .body = case_body,
                });
                self.skipNewlines();
                continue;
            }

            if (self.match(.keyword_default)) {
                if (default_branch != null) {
                    self.last_error = self.previous();
                    return error.DuplicateDefaultCase;
                }
                default_branch = try self.block();
                self.skipNewlines();
                continue;
            }

            self.failHere();
            return error.ExpectedCaseOrEnd;
        }

        _ = try self.consume(.keyword_end, error.ExpectedEnd);

        return .{
            .switch_stmt = .{
                .value = value,
                .cases = try cases.toOwnedSlice(self.allocator),
                .default_branch = default_branch,
            },
        };
    }

    fn functionStatement(self: *Parser) anyerror!ast.Stmt {
        const name = (try self.consume(.identifier, error.ExpectedFunctionName)).lexeme;
        _ = try self.consume(.keyword_takes, error.ExpectedTakes);

        var parameters: std.ArrayList([]const u8) = .empty;
        errdefer parameters.deinit(self.allocator);

        if (self.check(.identifier)) {
            while (true) {
                try parameters.append(
                    self.allocator,
                    (try self.consume(.identifier, error.ExpectedParameterName)).lexeme,
                );
                if (!self.match(.comma)) break;
            }
        }

        const body = try self.block();

        return .{
            .function = .{
                .name = name,
                .parameters = try parameters.toOwnedSlice(self.allocator),
                .body = body,
            },
        };
    }

    fn returnStatement(self: *Parser) anyerror!ast.Stmt {
        if (self.check(.newline) or self.check(.keyword_end) or self.check(.eof)) {
            try self.consumeLineEnd();
            return .{ .return_stmt = null };
        }

        const value = try self.expression();
        try self.consumeLineEnd();
        return .{ .return_stmt = value };
    }

    fn block(self: *Parser) anyerror![]ast.Stmt {
        self.skipNewlines();
        _ = try self.consume(.keyword_begin, error.ExpectedBegin);
        self.skipNewlines();

        var statements: std.ArrayList(ast.Stmt) = .empty;
        errdefer statements.deinit(self.allocator);

        while (!self.check(.keyword_end) and !self.check(.eof)) {
            try statements.append(self.allocator, try self.statement());
            self.skipNewlines();
        }

        _ = try self.consume(.keyword_end, error.ExpectedEnd);
        return try statements.toOwnedSlice(self.allocator);
    }

    fn expression(self: *Parser) anyerror!*ast.Expr {
        return self.orExpr();
    }

    fn orExpr(self: *Parser) anyerror!*ast.Expr {
        var expr = try self.andExpr();
        while (self.match(.keyword_or)) {
            expr = try self.makeBinary(expr, .keyword_or, try self.andExpr());
        }
        return expr;
    }

    fn andExpr(self: *Parser) anyerror!*ast.Expr {
        var expr = try self.equality();
        while (self.match(.keyword_and)) {
            expr = try self.makeBinary(expr, .keyword_and, try self.equality());
        }
        return expr;
    }

    fn equality(self: *Parser) anyerror!*ast.Expr {
        var expr = try self.comparison();
        while (true) {
            if (self.match(.keyword_equals)) {
                expr = try self.makeBinary(expr, .keyword_equals, try self.comparison());
            } else if (self.match(.keyword_not_equals)) {
                expr = try self.makeBinary(expr, .keyword_not_equals, try self.comparison());
            } else {
                break;
            }
        }
        return expr;
    }

    fn comparison(self: *Parser) anyerror!*ast.Expr {
        var expr = try self.term();
        while (true) {
            if (self.match(.keyword_greater)) {
                expr = try self.makeBinary(expr, .keyword_greater, try self.term());
            } else if (self.match(.keyword_less)) {
                expr = try self.makeBinary(expr, .keyword_less, try self.term());
            } else if (self.match(.keyword_at_least)) {
                expr = try self.makeBinary(expr, .keyword_at_least, try self.term());
            } else if (self.match(.keyword_at_most)) {
                expr = try self.makeBinary(expr, .keyword_at_most, try self.term());
            } else {
                break;
            }
        }
        return expr;
    }

    fn term(self: *Parser) anyerror!*ast.Expr {
        var expr = try self.factor();
        while (true) {
            if (self.match(.keyword_add)) {
                expr = try self.makeBinary(expr, .keyword_add, try self.factor());
            } else if (self.match(.keyword_subtract)) {
                expr = try self.makeBinary(expr, .keyword_subtract, try self.factor());
            } else {
                break;
            }
        }
        return expr;
    }

    fn factor(self: *Parser) anyerror!*ast.Expr {
        var expr = try self.unary();
        while (true) {
            if (self.match(.keyword_multiply)) {
                expr = try self.makeBinary(expr, .keyword_multiply, try self.unary());
            } else if (self.match(.keyword_divide)) {
                expr = try self.makeBinary(expr, .keyword_divide, try self.unary());
            } else if (self.match(.keyword_remainder)) {
                expr = try self.makeBinary(expr, .keyword_remainder, try self.unary());
            } else {
                break;
            }
        }
        return expr;
    }

    fn unary(self: *Parser) anyerror!*ast.Expr {
        if (self.match(.keyword_not)) {
            const right = try self.unary();
            const expr = try self.allocator.create(ast.Expr);
            expr.* = .{
                .unary = .{
                    .op = .keyword_not,
                    .right = right,
                },
            };
            return expr;
        }

        return self.primary();
    }

    fn primary(self: *Parser) anyerror!*ast.Expr {
        if (self.match(.integer)) {
            const token = self.previous();
            return self.makeLiteral(.{
                .integer = try std.fmt.parseInt(i64, token.lexeme, 10),
            });
        }

        if (self.match(.string)) {
            const token = self.previous();
            return self.makeLiteral(.{
                .string = token.lexeme[1 .. token.lexeme.len - 1],
            });
        }

        if (self.match(.keyword_true)) return self.makeLiteral(.{ .boolean = true });
        if (self.match(.keyword_false)) return self.makeLiteral(.{ .boolean = false });

        if (self.match(.keyword_call)) return self.callExpression();

        if (self.match(.identifier)) {
            const expr = try self.allocator.create(ast.Expr);
            expr.* = .{ .variable = self.previous().lexeme };
            return expr;
        }

        if (self.match(.l_paren)) {
            const expr = try self.expression();
            _ = try self.consume(.r_paren, error.ExpectedRightParen);
            return expr;
        }

        self.failHere();
        return error.ExpectedExpression;
    }

    fn callExpression(self: *Parser) anyerror!*ast.Expr {
        const name = (try self.consume(.identifier, error.ExpectedFunctionName)).lexeme;
        _ = try self.consume(.keyword_with, error.ExpectedWith);

        var arguments: std.ArrayList(*ast.Expr) = .empty;
        errdefer arguments.deinit(self.allocator);

        if (!self.check(.newline) and !self.check(.keyword_end) and !self.check(.eof) and !self.check(.r_paren)) {
            while (true) {
                try arguments.append(self.allocator, try self.expression());
                if (!self.match(.comma)) break;
            }
        }

        const expr = try self.allocator.create(ast.Expr);
        expr.* = .{
            .call = .{
                .name = name,
                .arguments = try arguments.toOwnedSlice(self.allocator),
            },
        };
        return expr;
    }

    fn makeLiteral(self: *Parser, value: Value) anyerror!*ast.Expr {
        const expr = try self.allocator.create(ast.Expr);
        expr.* = .{ .literal = value };
        return expr;
    }

    fn makeBinary(
        self: *Parser,
        left: *ast.Expr,
        op: lexer.TokenTag,
        right: *ast.Expr,
    ) anyerror!*ast.Expr {
        const expr = try self.allocator.create(ast.Expr);
        expr.* = .{
            .binary = .{
                .left = left,
                .op = op,
                .right = right,
            },
        };
        return expr;
    }

    fn consumeLineEnd(self: *Parser) anyerror!void {
        if (self.match(.newline)) {
            self.skipNewlines();
            return;
        }
        if (self.check(.keyword_end) or self.check(.eof)) return;
        self.failHere();
        return error.ExpectedLineEnd;
    }

    fn skipNewlines(self: *Parser) void {
        while (self.match(.newline)) {}
    }

    fn consume(self: *Parser, tag: lexer.TokenTag, err: anyerror) anyerror!lexer.Token {
        if (self.check(tag)) return self.advance();
        self.failHere();
        return err;
    }

    fn failHere(self: *Parser) void {
        self.last_error = self.peek();
    }

    fn match(self: *Parser, tag: lexer.TokenTag) bool {
        if (!self.check(tag)) return false;
        _ = self.advance();
        return true;
    }

    fn check(self: *Parser, tag: lexer.TokenTag) bool {
        return self.peek().tag == tag;
    }

    fn advance(self: *Parser) lexer.Token {
        if (!self.check(.eof)) self.current += 1;
        return self.previous();
    }

    fn peek(self: *Parser) lexer.Token {
        return self.tokens[self.current];
    }

    fn previous(self: *Parser) lexer.Token {
        return self.tokens[self.current - 1];
    }

    fn peekNextTag(self: *Parser) lexer.TokenTag {
        if (self.current + 1 >= self.tokens.len) return .eof;
        return self.tokens[self.current + 1].tag;
    }
};
