const std = @import("std");
const lexer = @import("lexer.zig");
const Value = @import("value.zig").Value;

pub const Expr = union(enum) {
    literal: Value,
    variable: []const u8,
    unary: struct { op: lexer.TokenTag, right: *Expr },
    binary: struct { left: *Expr, op: lexer.TokenTag, right: *Expr },
};

pub const ElseIfBranch = struct { condition: *Expr, body: []Stmt };

pub const Stmt = union(enum) {
    variable: struct { name: []const u8, value: *Expr },
    assign: struct { name: []const u8, value: *Expr },
    print: []*Expr,
    if_stmt: struct { condition: *Expr, then_branch: []Stmt, elif_branches: []ElseIfBranch, else_branch: ?[]Stmt },
    while_stmt: struct { condition: *Expr, body: []Stmt },
};

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: []const lexer.Token,
    current: usize = 0,

    pub fn init(allocator: std.mem.Allocator, tokens: []const lexer.Token) Parser { return .{ .allocator=allocator, .tokens=tokens }; }

    pub fn parseProgram(self: *Parser) ![]Stmt {
        var stmts: std.ArrayList(Stmt) = .empty;
        errdefer stmts.deinit(self.allocator);
        self.skipNewlines();
        while (!self.check(.eof)) { try stmts.append(self.allocator, try self.statement()); self.skipNewlines(); }
        return try stmts.toOwnedSlice(self.allocator);
    }

    fn statement(self: *Parser) !Stmt {
        if (self.match(.keyword_mutable)) return self.variableStatement();
        if (self.match(.keyword_print)) return self.printStatement();
        if (self.match(.keyword_if)) return self.ifStatement();
        if (self.match(.keyword_while)) return self.whileStatement();
        if (self.check(.identifier) and self.peekNextTag() == .keyword_becomes) return self.assignmentStatement();
        return error.ExpectedStatement;
    }

    fn variableStatement(self: *Parser) !Stmt {
        const name=(try self.consume(.identifier,error.ExpectedVariableName)).lexeme;
        _=try self.consume(.keyword_becomes,error.ExpectedBecomes);
        const value=try self.expression(); try self.consumeLineEnd();
        return .{ .variable=.{ .name=name, .value=value } };
    }

    fn assignmentStatement(self: *Parser) !Stmt {
        const name=self.advance().lexeme;
        _=try self.consume(.keyword_becomes,error.ExpectedBecomes);
        const value=try self.expression(); try self.consumeLineEnd();
        return .{ .assign=.{ .name=name, .value=value } };
    }

    fn printStatement(self: *Parser) !Stmt {
        _=try self.consume(.l_paren,error.ExpectedLeftParen);
        var args: std.ArrayList(*Expr)=.empty; errdefer args.deinit(self.allocator);
        if (!self.check(.r_paren)) {
            while (true) { try args.append(self.allocator,try self.expression()); if (!self.match(.comma)) break; }
        }
        _=try self.consume(.r_paren,error.ExpectedRightParen); try self.consumeLineEnd();
        return .{ .print=try args.toOwnedSlice(self.allocator) };
    }

    fn ifStatement(self: *Parser) !Stmt {
        const condition=try self.expression();
        const then_branch=try self.block();
        var elifs: std.ArrayList(ElseIfBranch)=.empty; errdefer elifs.deinit(self.allocator);
        var else_branch:?[]Stmt=null;
        self.skipNewlines();
        while (self.match(.keyword_else)) {
            if (self.match(.keyword_if)) {
                const c=try self.expression(); const b=try self.block();
                try elifs.append(self.allocator,.{ .condition=c,.body=b }); self.skipNewlines();
            } else { else_branch=try self.block(); break; }
        }
        return .{ .if_stmt=.{ .condition=condition,.then_branch=then_branch,.elif_branches=try elifs.toOwnedSlice(self.allocator),.else_branch=else_branch } };
    }

    fn whileStatement(self: *Parser) !Stmt {
        const condition=try self.expression(); const body=try self.block();
        return .{ .while_stmt=.{ .condition=condition,.body=body } };
    }

    fn block(self: *Parser) ![]Stmt {
        self.skipNewlines(); _=try self.consume(.keyword_begin,error.ExpectedBegin); self.skipNewlines();
        var stmts: std.ArrayList(Stmt)=.empty; errdefer stmts.deinit(self.allocator);
        while (!self.check(.keyword_end) and !self.check(.eof)) { try stmts.append(self.allocator,try self.statement()); self.skipNewlines(); }
        _=try self.consume(.keyword_end,error.ExpectedEnd);
        return try stmts.toOwnedSlice(self.allocator);
    }

    fn expression(self:*Parser) anyerror!*Expr{return self.orExpr();}
    fn orExpr(self:*Parser) anyerror!*Expr{var e=try self.andExpr();while(self.match(.keyword_or))e=try self.makeBinary(e,.keyword_or,try self.andExpr());return e;}
    fn andExpr(self:*Parser) anyerror!*Expr{var e=try self.equality();while(self.match(.keyword_and))e=try self.makeBinary(e,.keyword_and,try self.equality());return e;}
    fn equality(self:*Parser) anyerror!*Expr{var e=try self.comparison();while(true){if(self.match(.keyword_equals))e=try self.makeBinary(e,.keyword_equals,try self.comparison()) else if(self.match(.keyword_not_equals))e=try self.makeBinary(e,.keyword_not_equals,try self.comparison()) else break;}return e;}
    fn comparison(self:*Parser) anyerror!*Expr{var e=try self.term();while(true){if(self.match(.keyword_greater))e=try self.makeBinary(e,.keyword_greater,try self.term()) else if(self.match(.keyword_less))e=try self.makeBinary(e,.keyword_less,try self.term()) else if(self.match(.keyword_at_least))e=try self.makeBinary(e,.keyword_at_least,try self.term()) else if(self.match(.keyword_at_most))e=try self.makeBinary(e,.keyword_at_most,try self.term()) else break;}return e;}
    fn term(self:*Parser) anyerror!*Expr{var e=try self.factor();while(true){if(self.match(.keyword_add))e=try self.makeBinary(e,.keyword_add,try self.factor()) else if(self.match(.keyword_subtract))e=try self.makeBinary(e,.keyword_subtract,try self.factor()) else break;}return e;}
    fn factor(self:*Parser) anyerror!*Expr{var e=try self.unary();while(true){if(self.match(.keyword_multiply))e=try self.makeBinary(e,.keyword_multiply,try self.unary()) else if(self.match(.keyword_divide))e=try self.makeBinary(e,.keyword_divide,try self.unary()) else if(self.match(.keyword_remainder))e=try self.makeBinary(e,.keyword_remainder,try self.unary()) else break;}return e;}
    fn unary(self:*Parser) anyerror!*Expr{if(self.match(.keyword_not)){const r=try self.unary();const e=try self.allocator.create(Expr);e.*=.{.unary=.{.op=.keyword_not,.right=r}};return e;}return self.primary();}

    fn primary(self:*Parser) anyerror!*Expr{
        if(self.match(.integer)){const t=self.previous();return self.makeLiteral(.{.integer=try std.fmt.parseInt(i64,t.lexeme,10)});}
        if(self.match(.string)){const t=self.previous();return self.makeLiteral(.{.string=t.lexeme[1..t.lexeme.len-1]});}
        if(self.match(.keyword_true))return self.makeLiteral(.{.boolean=true});
        if(self.match(.keyword_false))return self.makeLiteral(.{.boolean=false});
        if(self.match(.identifier)){const e=try self.allocator.create(Expr);e.*=.{.variable=self.previous().lexeme};return e;}
        if(self.match(.l_paren)){const e=try self.expression();_=try self.consume(.r_paren,error.ExpectedRightParen);return e;}
        return error.ExpectedExpression;
    }

    fn makeLiteral(self:*Parser,value:Value) anyerror!*Expr{const e=try self.allocator.create(Expr);e.*=.{.literal=value};return e;}
    fn makeBinary(self:*Parser,left:*Expr,op:lexer.TokenTag,right:*Expr) anyerror!*Expr{const e=try self.allocator.create(Expr);e.*=.{.binary=.{.left=left,.op=op,.right=right}};return e;}
    fn consumeLineEnd(self:*Parser) anyerror!void{if(self.match(.newline)){self.skipNewlines();return;}if(self.check(.keyword_end) or self.check(.eof))return;return error.ExpectedLineEnd;}
    fn skipNewlines(self:*Parser)void{while(self.match(.newline)){} }
    fn consume(self:*Parser,tag:lexer.TokenTag,err:anyerror) anyerror!lexer.Token{if(self.check(tag))return self.advance();return err;}
    fn match(self:*Parser,tag:lexer.TokenTag)bool{if(!self.check(tag))return false;_=self.advance();return true;}
    fn check(self:*Parser,tag:lexer.TokenTag)bool{return self.peek().tag==tag;}
    fn advance(self:*Parser)lexer.Token{if(!self.check(.eof))self.current+=1;return self.previous();}
    fn peek(self:*Parser)lexer.Token{return self.tokens[self.current];}
    fn previous(self:*Parser)lexer.Token{return self.tokens[self.current-1];}
    fn peekNextTag(self:*Parser)lexer.TokenTag{if(self.current+1>=self.tokens.len)return .eof;return self.tokens[self.current+1].tag;}
};

pub fn deinitProgram(allocator: std.mem.Allocator, statements: []Stmt) void {
    deinitStatements(allocator, statements);
    allocator.free(statements);
}

fn deinitStatements(allocator: std.mem.Allocator, statements: []Stmt) void {
    for (statements) |statement| {
        deinitStatement(allocator, statement);
    }
}

fn deinitStatement(allocator: std.mem.Allocator, statement: Stmt) void {
    switch (statement) {
        .variable => |node| {
            deinitExpr(allocator, node.value);
        },
        .assign => |node| {
            deinitExpr(allocator, node.value);
        },
        .print => |arguments| {
            for (arguments) |argument| {
                deinitExpr(allocator, argument);
            }
            allocator.free(arguments);
        },
        .if_stmt => |node| {
            deinitExpr(allocator, node.condition);

            deinitStatements(allocator, node.then_branch);
            allocator.free(node.then_branch);

            for (node.elif_branches) |branch| {
                deinitExpr(allocator, branch.condition);
                deinitStatements(allocator, branch.body);
                allocator.free(branch.body);
            }
            allocator.free(node.elif_branches);

            if (node.else_branch) |branch| {
                deinitStatements(allocator, branch);
                allocator.free(branch);
            }
        },
        .while_stmt => |node| {
            deinitExpr(allocator, node.condition);
            deinitStatements(allocator, node.body);
            allocator.free(node.body);
        },
    }
}

fn deinitExpr(allocator: std.mem.Allocator, expr: *Expr) void {
    switch (expr.*) {
        .literal, .variable => {},
        .unary => |node| {
            deinitExpr(allocator, node.right);
        },
        .binary => |node| {
            deinitExpr(allocator, node.left);
            deinitExpr(allocator, node.right);
        },
    }

    allocator.destroy(expr);
}
