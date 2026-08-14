const std = @import("std");
const parser = @import("parser.zig");
const lexer = @import("lexer.zig");
const Value = @import("value.zig").Value;

const RuntimeError = error{
    VariableAlreadyExists,
    UnknownVariable,
    ExpectedBoolean,
    ExpectedInteger,
    UnsupportedUnaryOperator,
    UnsupportedBinaryOperator,
    DivisionByZero,
} || std.mem.Allocator.Error;

pub const Interpreter = struct {
    allocator: std.mem.Allocator,
    variables: std.StringHashMap(Value),

    pub fn init(allocator: std.mem.Allocator) Interpreter {
        return .{
            .allocator = allocator,
            .variables = std.StringHashMap(Value).init(allocator),
        };
    }

    pub fn deinit(self: *Interpreter) void {
        self.variables.deinit();
    }

    pub fn run(self: *Interpreter, statements: []const parser.Stmt) RuntimeError!void {
        for (statements) |statement| {
            try self.execute(statement);
        }
    }

    fn execute(self: *Interpreter, statement: parser.Stmt) RuntimeError!void {
        switch (statement) {
            .variable => |variable| {
                if (self.variables.contains(variable.name)) {
                    return error.VariableAlreadyExists;
                }

                const value = try self.eval(variable.value);
                try self.variables.put(variable.name, value);
            },
            .assign => |assignment| {
                if (!self.variables.contains(assignment.name)) {
                    return error.UnknownVariable;
                }

                const value = try self.eval(assignment.value);
                try self.variables.put(assignment.name, value);
            },
            .print => |arguments| {
                for (arguments, 0..) |argument, index| {
                    const value = try self.eval(argument);

                    if (index != 0) {
                        std.debug.print(" ", .{});
                    }

                    switch (value) {
                        .integer => |number| std.debug.print("{}", .{number}),
                        .string => |text| std.debug.print("{s}", .{text}),
                        .boolean => |boolean| {
                            std.debug.print(
                                "{s}",
                                .{if (boolean) "авжеж" else "ані"},
                            );
                        },
                    }
                }

                std.debug.print("\n", .{});
            },
            .if_stmt => |node| {
                if (try self.truthy(try self.eval(node.condition))) {
                    try self.run(node.then_branch);
                    return;
                }

                for (node.elif_branches) |branch| {
                    if (try self.truthy(try self.eval(branch.condition))) {
                        try self.run(branch.body);
                        return;
                    }
                }

                if (node.else_branch) |branch| {
                    try self.run(branch);
                }
            },
            .while_stmt => |node| {
                while (try self.truthy(try self.eval(node.condition))) {
                    try self.run(node.body);
                }
            },
        }
    }

    fn eval(self: *Interpreter, expr: *const parser.Expr) RuntimeError!Value {
        return switch (expr.*) {
            .literal => |value| value,

            .variable => |name| self.variables.get(name) orelse
                error.UnknownVariable,

            .unary => |node| blk: {
                const right = try self.eval(node.right);

                break :blk switch (node.op) {
                    .keyword_not => .{
                        .boolean = !(try self.truthy(right)),
                    },
                    else => error.UnsupportedUnaryOperator,
                };
            },

            .binary => |node| blk: {
                const left = try self.eval(node.left);
                const right = try self.eval(node.right);

                break :blk switch (node.op) {
                    .keyword_add => try numericBinary(left, right, .add),
                    .keyword_subtract => try numericBinary(left, right, .sub),
                    .keyword_multiply => try numericBinary(left, right, .mul),
                    .keyword_divide => try numericBinary(left, right, .div),
                    .keyword_remainder => try numericBinary(left, right, .mod),

                    .keyword_equals => .{
                        .boolean = valuesEqual(left, right),
                    },
                    .keyword_not_equals => .{
                        .boolean = !valuesEqual(left, right),
                    },

                    .keyword_greater => try numericCompare(left, right, .gt),
                    .keyword_less => try numericCompare(left, right, .lt),
                    .keyword_at_least => try numericCompare(left, right, .gte),
                    .keyword_at_most => try numericCompare(left, right, .lte),

                    .keyword_and => .{
                        .boolean = (try self.truthy(left)) and
                            (try self.truthy(right)),
                    },
                    .keyword_or => .{
                        .boolean = (try self.truthy(left)) or
                            (try self.truthy(right)),
                    },

                    else => error.UnsupportedBinaryOperator,
                };
            },
        };
    }

    fn truthy(self: *Interpreter, value: Value) RuntimeError!bool {
        _ = self;

        return switch (value) {
            .boolean => |boolean| boolean,
            else => error.ExpectedBoolean,
        };
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

fn numericBinary(left: Value, right: Value, op: NumericOp) RuntimeError!Value {
    const a = switch (left) {
        .integer => |value| value,
        else => return error.ExpectedInteger,
    };

    const b = switch (right) {
        .integer => |value| value,
        else => return error.ExpectedInteger,
    };

    if ((op == .div or op == .mod) and b == 0) {
        return error.DivisionByZero;
    }

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
    const a = switch (left) {
        .integer => |value| value,
        else => return error.ExpectedInteger,
    };

    const b = switch (right) {
        .integer => |value| value,
        else => return error.ExpectedInteger,
    };

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
    };
}
