const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const ast = @import("ast.zig");
const Interpreter = @import("interpreter.zig").Interpreter;
const root = @import("root.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;
    const cwd = std.Io.Dir.cwd();
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len < 2) {
        printHelp();
        return;
    }

    if (std.mem.eql(u8, args[1], "--version")) {
        std.debug.print("compiler {s}\n", .{root.compiler_version});
        return;
    }

    if (std.mem.eql(u8, args[1], "--help")) {
        printHelp();
        return;
    }

    var dump_tokens = false;
    var file_name: []const u8 = undefined;

    if (std.mem.eql(u8, args[1], "--tokens")) {
        if (args.len < 3) {
            std.debug.print("Лихо: після --tokens потрібен файл .ukr\n", .{});
            return;
        }
        dump_tokens = true;
        file_name = args[2];
    } else {
        file_name = args[1];
    }

    const source = try cwd.readFileAlloc(
        io,
        file_name,
        allocator,
        .limited(4 * 1024 * 1024),
    );
    defer allocator.free(source);

    var lex_diagnostic: ?lexer.Diagnostic = null;
    const tokens = lexer.lex(allocator, source, &lex_diagnostic) catch |err| {
        if (lex_diagnostic) |diagnostic| {
            printDiagnostic(source, @errorName(err), diagnostic.line, diagnostic.column, "");
        } else {
            std.debug.print("Лихо під час лексичного розбору: {s}\n", .{@errorName(err)});
        }
        return;
    };
    defer allocator.free(tokens);

    if (dump_tokens) {
        for (tokens) |token| {
            std.debug.print(
                "{d}:{d}  {s}  {s}\n",
                .{ token.line, token.column, @tagName(token.tag), token.lexeme },
            );
        }
        return;
    }

    var p = parser.Parser.init(allocator, tokens);
    const statements = p.parseProgram() catch |err| {
        if (p.errorToken()) |token| {
            printDiagnostic(source, @errorName(err), token.line, token.column, token.lexeme);
            printHint(err);
        } else {
            std.debug.print("Лихо під час синтаксичного розбору: {s}\n", .{@errorName(err)});
        }
        return;
    };
    defer ast.deinitProgram(allocator, statements);

    var interpreter = Interpreter.init(allocator);
    defer interpreter.deinit();

    interpreter.runProgram(statements) catch |err| {
        std.debug.print("Лихо під час виконання: {s}\n", .{@errorName(err)});
    };
}

fn printHelp() void {
    std.debug.print(
        \\Real Ukrainian Programming Language compiler 0.0.2
        \\
        \\Використання:
        \\  compiler <файл.ukr>
        \\  compiler --tokens <файл.ukr>
        \\  compiler --version
        \\  compiler --help
        \\
    , .{});
}

fn printHint(err: anyerror) void {
    switch (err) {
        error.DeclarationRequiresBecame => std.debug.print(
            "Підказка: оголошення використовує «став», а зміна значення — «стає».\n",
            .{},
        ),
        error.BecameOnlyForDeclaration => std.debug.print(
            "Підказка: «став» дозволено лише після «мінливе <назва>». Для зміни значення використайте «стає».\n",
            .{},
        ),
        else => {},
    }
}

fn printDiagnostic(
    source: []const u8,
    name: []const u8,
    line: usize,
    column: usize,
    lexeme: []const u8,
) void {
    std.debug.print("Лихо: {s} на {d}:{d}", .{ name, line, column });
    if (lexeme.len > 0) std.debug.print(" біля «{s}»", .{lexeme});
    std.debug.print("\n", .{});

    if (sourceLine(source, line)) |text| {
        std.debug.print("{d} | {s}\n", .{ line, text });
        std.debug.print("  | ", .{});
        var i: usize = 1;
        while (i < column) : (i += 1) std.debug.print(" ", .{});
        std.debug.print("^\n", .{});
    }
}

fn sourceLine(source: []const u8, wanted_line: usize) ?[]const u8 {
    var line: usize = 1;
    var start: usize = 0;
    var i: usize = 0;

    while (i <= source.len) : (i += 1) {
        if (i == source.len or source[i] == '\n') {
            if (line == wanted_line) {
                var end = i;
                if (end > start and source[end - 1] == '\r') end -= 1;
                return source[start..end];
            }
            line += 1;
            start = i + 1;
        }
    }

    return null;
}
