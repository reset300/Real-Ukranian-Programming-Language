const std = @import("std");
const lexer = @import("lexer.zig");
const parser = @import("parser.zig");
const Interpreter = @import("interpreter.zig").Interpreter;

pub fn main(init: std.process.Init) !void {
    const allocator=init.gpa; const io=init.io; const cwd=std.Io.Dir.cwd();
    const args=try init.minimal.args.toSlice(init.arena.allocator());
    if(args.len<2){std.debug.print("Використання: compiler <файл.ukr>\\n",.{});return;}
    const source=try cwd.readFileAlloc(io,args[1],allocator,.limited(4*1024*1024)); defer allocator.free(source);
    const tokens=lexer.lex(allocator,source)catch|err|{std.debug.print("Лихо під час лексичного розбору: {s}\\n",.{@errorName(err)});return;}; defer allocator.free(tokens);
    var p=parser.Parser.init(allocator,tokens);
    const statements=p.parseProgram()catch|err|{std.debug.print("Лихо під час синтаксичного розбору: {s}\\n",.{@errorName(err)});return;}; defer parser.deinitProgram(allocator, statements);
    var interpreter=Interpreter.init(allocator); defer interpreter.deinit();
    interpreter.run(statements)catch|err|{std.debug.print("Лихо під час виконання: {s}\\n",.{@errorName(err)});};
}
