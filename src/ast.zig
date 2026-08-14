const std = @import("std");
const lexer = @import("lexer.zig");
const Value = @import("value.zig").Value;

pub const Expr = union(enum) {
    literal: Value,
    variable: []const u8,
    unary: struct {
        op: lexer.TokenTag,
        right: *Expr,
    },
    binary: struct {
        left: *Expr,
        op: lexer.TokenTag,
        right: *Expr,
    },
    call: struct {
        name: []const u8,
        arguments: []*Expr,
    },
};

pub const ElseIfBranch = struct {
    condition: *Expr,
    body: []Stmt,
};

pub const SwitchCase = struct {
    value: *Expr,
    body: []Stmt,
};

pub const Function = struct {
    name: []const u8,
    parameters: [][]const u8,
    body: []Stmt,
};

pub const Stmt = union(enum) {
    variable: struct {
        name: []const u8,
        value: *Expr,
    },
    assign: struct {
        name: []const u8,
        value: *Expr,
    },
    print: []*Expr,
    expression: *Expr,
    if_stmt: struct {
        condition: *Expr,
        then_branch: []Stmt,
        elif_branches: []ElseIfBranch,
        else_branch: ?[]Stmt,
    },
    while_stmt: struct {
        condition: *Expr,
        body: []Stmt,
    },
    for_range: struct {
        name: []const u8,
        start: *Expr,
        end: *Expr,
        body: []Stmt,
    },
    switch_stmt: struct {
        value: *Expr,
        cases: []SwitchCase,
        default_branch: ?[]Stmt,
    },
    function: Function,
    return_stmt: ?*Expr,
    break_stmt,
    continue_stmt,
};

pub fn deinitProgram(allocator: std.mem.Allocator, statements: []Stmt) void {
    deinitStatements(allocator, statements);
    allocator.free(statements);
}

pub fn deinitStatements(allocator: std.mem.Allocator, statements: []Stmt) void {
    for (statements) |statement| {
        deinitStatement(allocator, statement);
    }
}

fn deinitStatement(allocator: std.mem.Allocator, statement: Stmt) void {
    switch (statement) {
        .variable => |node| deinitExpr(allocator, node.value),
        .assign => |node| deinitExpr(allocator, node.value),
        .print => |arguments| {
            for (arguments) |argument| deinitExpr(allocator, argument);
            allocator.free(arguments);
        },
        .expression => |expr| deinitExpr(allocator, expr),
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
        .for_range => |node| {
            deinitExpr(allocator, node.start);
            deinitExpr(allocator, node.end);
            deinitStatements(allocator, node.body);
            allocator.free(node.body);
        },
        .switch_stmt => |node| {
            deinitExpr(allocator, node.value);
            for (node.cases) |case_node| {
                deinitExpr(allocator, case_node.value);
                deinitStatements(allocator, case_node.body);
                allocator.free(case_node.body);
            }
            allocator.free(node.cases);
            if (node.default_branch) |branch| {
                deinitStatements(allocator, branch);
                allocator.free(branch);
            }
        },
        .function => |function| {
            allocator.free(function.parameters);
            deinitStatements(allocator, function.body);
            allocator.free(function.body);
        },
        .return_stmt => |maybe_expr| {
            if (maybe_expr) |expr| deinitExpr(allocator, expr);
        },
        .break_stmt, .continue_stmt => {},
    }
}

pub fn deinitExpr(allocator: std.mem.Allocator, expr: *Expr) void {
    switch (expr.*) {
        .literal, .variable => {},
        .unary => |node| deinitExpr(allocator, node.right),
        .binary => |node| {
            deinitExpr(allocator, node.left);
            deinitExpr(allocator, node.right);
        },
        .call => |node| {
            for (node.arguments) |argument| deinitExpr(allocator, argument);
            allocator.free(node.arguments);
        },
    }
    allocator.destroy(expr);
}
