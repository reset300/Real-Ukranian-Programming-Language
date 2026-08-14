const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");
const Value = @import("value.zig").Value;

const RuntimeError = error{
    VariableAlreadyExists,
    UnknownVariable,
    FunctionAlreadyExists,
    UnknownFunction,
    WrongArgumentCount,
    ExpectedBoolean,
    ExpectedInteger,
    UnsupportedUnaryOperator,
    UnsupportedBinaryOperator,
    DivisionByZero,
    BreakOutsideLoop,
    ContinueOutsideLoop,
    ReturnOutsideFunction,
} || std.mem.Allocator.Error;

const ExecSignal = union(enum) {
    normal,
    break_loop,
    continue_loop,
    returned: Value,
};

pub const Interpreter = struct {
    allocator: std.mem.Allocator,
    globals: std.StringHashMap(Value),
    locals: std.ArrayList(std.StringHashMap(Value)),
    functions: std.StringHashMap(ast.Function),
    loop_depth: usize = 0,
    call_depth: usize = 0,

    pub fn init(allocator: std.mem.Allocator) Interpreter {
        return .{
            .allocator = allocator,
            .globals = std.StringHashMap(Value).init(allocator),
            .locals = .empty,
            .functions = std.StringHashMap(ast.Function).init(allocator),
        };
    }

    pub fn deinit(self: *Interpreter) void {
        while (self.locals.items.len > 0) self.popScope();
        self.locals.deinit(self.allocator);
        self.functions.deinit();
        self.globals.deinit();
    }

    pub fn runProgram(self: *Interpreter, statements: []const ast.Stmt) RuntimeError!void {
        for (statements) |statement| {
            switch (statement) {
                .function => |function| try self.registerFunction(function),
                else => {},
            }
        }

        const signal = try self.runStatements(statements);
        switch (signal) {
            .normal => {},
            .break_loop => return error.BreakOutsideLoop,
            .continue_loop => return error.ContinueOutsideLoop,
            .returned => return error.ReturnOutsideFunction,
        }
    }

    fn registerFunction(self: *Interpreter, function: ast.Function) RuntimeError!void {
        if (self.functions.contains(function.name)) return error.FunctionAlreadyExists;
        try self.functions.put(function.name, function);
    }

    fn runStatements(self: *Interpreter, statements: []const ast.Stmt) RuntimeError!ExecSignal {
        for (statements) |statement| {
            const signal = try self.execute(statement);
            switch (signal) {
                .normal => {},
                else => return signal,
            }
        }
        return .normal;
    }

    fn executeBlock(self: *Interpreter, statements: []const ast.Stmt) RuntimeError!ExecSignal {
        try self.pushScope();
        defer self.popScope();
        return self.runStatements(statements);
    }

    fn execute(self: *Interpreter, statement: ast.Stmt) RuntimeError!ExecSignal {
        return switch (statement) {
            .variable => |node| blk: {
                if (self.currentContains(node.name)) return error.VariableAlreadyExists;
                const value = try self.eval(node.value);
                try self.putCurrent(node.name, value);
                break :blk .normal;
            },
            .assign => |node| blk: {
                const value = try self.eval(node.value);
                try self.assign(node.name, value);
                break :blk .normal;
            },
            .print => |arguments| blk: {
                for (arguments, 0..) |argument, index| {
                    if (index != 0) std.debug.print(" ", .{});
                    (try self.eval(argument)).writeInline();
                }
                std.debug.print("\n", .{});
                break :blk .normal;
            },
            .expression => |expr| blk: {
                _ = try self.eval(expr);
                break :blk .normal;
            },
            .if_stmt => |node| try self.executeIf(node),
            .while_stmt => |node| try self.executeWhile(node),
            .for_range => |node| try self.executeFor(node),
            .switch_stmt => |node| try self.executeSwitch(node),
            .function => .normal,
            .return_stmt => |maybe_expr| blk: {
                if (self.call_depth == 0) return error.ReturnOutsideFunction;
                const value = if (maybe_expr) |expr| try self.eval(expr) else Value{ .nothing = {} };
                break :blk .{ .returned = value };
            },
            .break_stmt => blk: {
                if (self.loop_depth == 0) return error.BreakOutsideLoop;
                break :blk .break_loop;
            },
            .continue_stmt => blk: {
                if (self.loop_depth == 0) return error.ContinueOutsideLoop;
                break :blk .continue_loop;
            },
        };
    }

    fn executeIf(self: *Interpreter, node: anytype) RuntimeError!ExecSignal {
        if (try self.truthy(try self.eval(node.condition))) {
            return self.executeBlock(node.then_branch);
        }

        for (node.elif_branches) |branch| {
            if (try self.truthy(try self.eval(branch.condition))) {
                return self.executeBlock(branch.body);
            }
        }

        if (node.else_branch) |branch| return self.executeBlock(branch);
        return .normal;
    }

    fn executeWhile(self: *Interpreter, node: anytype) RuntimeError!ExecSignal {
        self.loop_depth += 1;
        defer self.loop_depth -= 1;

        while (try self.truthy(try self.eval(node.condition))) {
            const signal = try self.executeBlock(node.body);
            switch (signal) {
                .normal, .continue_loop => {},
                .break_loop => return .normal,
                .returned => return signal,
            }
        }

        return .normal;
    }

    fn executeFor(self: *Interpreter, node: anytype) RuntimeError!ExecSignal {
        const start_value = try self.eval(node.start);
        const end_value = try self.eval(node.end);
        const start = try integerValue(start_value);
        const end = try integerValue(end_value);

        try self.pushScope();
        defer self.popScope();

        try self.putCurrent(node.name, .{ .integer = start });
        self.loop_depth += 1;
        defer self.loop_depth -= 1;

        var current = start;
        while (current < end) : (current += 1) {
            try self.assign(node.name, .{ .integer = current });
            const signal = try self.executeBlock(node.body);
            switch (signal) {
                .normal, .continue_loop => {},
                .break_loop => return .normal,
                .returned => return signal,
            }
        }

        return .normal;
    }

    fn executeSwitch(self: *Interpreter, node: anytype) RuntimeError!ExecSignal {
        const selected = try self.eval(node.value);

        for (node.cases) |case_node| {
            const candidate = try self.eval(case_node.value);
            if (valuesEqual(selected, candidate)) {
                return self.executeBlock(case_node.body);
            }
        }

        if (node.default_branch) |branch| return self.executeBlock(branch);
        return .normal;
    }

    fn eval(self: *Interpreter, expr: *const ast.Expr) RuntimeError!Value {
        return switch (expr.*) {
            .literal => |value| value,
            .variable => |name| self.get(name) orelse error.UnknownVariable,
            .unary => |node| blk: {
                const right = try self.eval(node.right);
                break :blk switch (node.op) {
                    .keyword_not => .{ .boolean = !(try self.truthy(right)) },
                    else => error.UnsupportedUnaryOperator,
                };
            },
            .binary => |node| try self.evalBinary(node.left, node.op, node.right),
            .call => |node| try self.callFunction(node.name, node.arguments),
        };
    }

    fn evalBinary(
        self: *Interpreter,
        left_expr: *ast.Expr,
        op: lexer.TokenTag,
        right_expr: *ast.Expr,
    ) RuntimeError!Value {
        if (op == .keyword_and) {
            const left = try self.truthy(try self.eval(left_expr));
            if (!left) return .{ .boolean = false };
            return .{ .boolean = try self.truthy(try self.eval(right_expr)) };
        }

        if (op == .keyword_or) {
            const left = try self.truthy(try self.eval(left_expr));
            if (left) return .{ .boolean = true };
            return .{ .boolean = try self.truthy(try self.eval(right_expr)) };
        }

        const left = try self.eval(left_expr);
        const right = try self.eval(right_expr);

        return switch (op) {
            .keyword_add => try numericBinary(left, right, .add),
            .keyword_subtract => try numericBinary(left, right, .sub),
            .keyword_multiply => try numericBinary(left, right, .mul),
            .keyword_divide => try numericBinary(left, right, .div),
            .keyword_remainder => try numericBinary(left, right, .mod),
            .keyword_equals => .{ .boolean = valuesEqual(left, right) },
            .keyword_not_equals => .{ .boolean = !valuesEqual(left, right) },
            .keyword_greater => try numericCompare(left, right, .gt),
            .keyword_less => try numericCompare(left, right, .lt),
            .keyword_at_least => try numericCompare(left, right, .gte),
            .keyword_at_most => try numericCompare(left, right, .lte),
            else => error.UnsupportedBinaryOperator,
        };
    }

    fn callFunction(
        self: *Interpreter,
        name: []const u8,
        argument_exprs: []*ast.Expr,
    ) RuntimeError!Value {
        const function = self.functions.get(name) orelse return error.UnknownFunction;
        if (function.parameters.len != argument_exprs.len) return error.WrongArgumentCount;

        var arguments: std.ArrayList(Value) = .empty;
        defer arguments.deinit(self.allocator);

        for (argument_exprs) |argument_expr| {
            try arguments.append(self.allocator, try self.eval(argument_expr));
        }

        try self.pushScope();
        defer self.popScope();

        for (function.parameters, arguments.items) |parameter, value| {
            try self.putCurrent(parameter, value);
        }

        self.call_depth += 1;
        defer self.call_depth -= 1;

        const signal = try self.runStatements(function.body);
        return switch (signal) {
            .normal => Value{ .nothing = {} },
            .returned => |value| value,
            .break_loop => error.BreakOutsideLoop,
            .continue_loop => error.ContinueOutsideLoop,
        };
    }

    fn truthy(self: *Interpreter, value: Value) RuntimeError!bool {
        _ = self;
        return switch (value) {
            .boolean => |boolean| boolean,
            else => error.ExpectedBoolean,
        };
    }

    fn pushScope(self: *Interpreter) RuntimeError!void {
        try self.locals.append(
            self.allocator,
            std.StringHashMap(Value).init(self.allocator),
        );
    }

    fn popScope(self: *Interpreter) void {
        var scope = self.locals.pop().?;
        scope.deinit();
    }

    fn currentContains(self: *Interpreter, name: []const u8) bool {
        if (self.locals.items.len == 0) return self.globals.contains(name);
        return self.locals.items[self.locals.items.len - 1].contains(name);
    }

    fn putCurrent(self: *Interpreter, name: []const u8, value: Value) RuntimeError!void {
        if (self.locals.items.len == 0) {
            try self.globals.put(name, value);
            return;
        }
        try self.locals.items[self.locals.items.len - 1].put(name, value);
    }

    fn get(self: *Interpreter, name: []const u8) ?Value {
        var index = self.locals.items.len;
        while (index > 0) {
            index -= 1;
            if (self.locals.items[index].get(name)) |value| return value;
        }
        return self.globals.get(name);
    }

    fn assign(self: *Interpreter, name: []const u8, value: Value) RuntimeError!void {
        var index = self.locals.items.len;
        while (index > 0) {
            index -= 1;
            if (self.locals.items[index].contains(name)) {
                try self.locals.items[index].put(name, value);
                return;
            }
        }

        if (self.globals.contains(name)) {
            try self.globals.put(name, value);
            return;
        }

        return error.UnknownVariable;
    }
};

const NumericOp = enum {
    add,
    sub,
    mul,
    div,
    mod,
};

const CompareOp = enum {
    gt,
    lt,
    gte,
    lte,
};

fn integerValue(value: Value) RuntimeError!i64 {
    return switch (value) {
        .integer => |integer| integer,
        else => error.ExpectedInteger,
    };
}

fn numericBinary(left: Value, right: Value, op: NumericOp) RuntimeError!Value {
    const a = try integerValue(left);
    const b = try integerValue(right);

    if ((op == .div or op == .mod) and b == 0) return error.DivisionByZero;

    return .{
        .integer = switch (op) {
            .add => a + b,
            .sub => a - b,
            .mul => a * b,
            .div => @divTrunc(a, b),
            .mod => @mod(a, b),
        },
    };
}

fn numericCompare(left: Value, right: Value, op: CompareOp) RuntimeError!Value {
    const a = try integerValue(left);
    const b = try integerValue(right);

    return .{
        .boolean = switch (op) {
            .gt => a > b,
            .lt => a < b,
            .gte => a >= b,
            .lte => a <= b,
        },
    };
}

fn valuesEqual(left: Value, right: Value) bool {
    return switch (left) {
        .integer => |a| switch (right) {
            .integer => |b| a == b,
            else => false,
        },
        .string => |a| switch (right) {
            .string => |b| std.mem.eql(u8, a, b),
            else => false,
        },
        .boolean => |a| switch (right) {
            .boolean => |b| a == b,
            else => false,
        },
        .nothing => switch (right) {
            .nothing => true,
            else => false,
        },
    };
}
