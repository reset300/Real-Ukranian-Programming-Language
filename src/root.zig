const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const ast = @import("ast.zig");

pub const compiler_version = "0.0.2";

test "0.0.2 declaration syntax parses" {
    const source =
        \\мінливе число став 10
        \\число стає число додати 1
    ;

    var diagnostic: ?lexer.Diagnostic = null;
    const tokens = try lexer.lex(std.testing.allocator, source, &diagnostic);
    defer std.testing.allocator.free(tokens);

    var p = parser.Parser.init(std.testing.allocator, tokens);
    const statements = try p.parseProgram();
    defer ast.deinitProgram(std.testing.allocator, statements);

    try std.testing.expectEqual(@as(usize, 2), statements.len);
}

test "0.0.2 extended syntax parses" {
    const source =
        \\чин додати бере а, б
        \\зачин
        \\    віддати а додати б
        \\край
        \\
        \\мінливе сума став вжити додати з 2, 3
        \\перебрати число від 0 до 3
        \\зачин
        \\    вивести(число)
        \\край
    ;

    var diagnostic: ?lexer.Diagnostic = null;
    const tokens = try lexer.lex(std.testing.allocator, source, &diagnostic);
    defer std.testing.allocator.free(tokens);

    var p = parser.Parser.init(std.testing.allocator, tokens);
    const statements = try p.parseProgram();
    defer ast.deinitProgram(std.testing.allocator, statements);

    try std.testing.expectEqual(@as(usize, 3), statements.len);
}
