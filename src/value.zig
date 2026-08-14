const std = @import("std");

pub const Value = union(enum) {
    integer: i64,
    string: []const u8,
    boolean: bool,

    pub fn print(self: Value) void {
        switch (self) {
            .integer => |v| std.debug.print("{}\\n", .{v}),
            .string => |v| std.debug.print("{s}\\n", .{v}),
            .boolean => |v| std.debug.print("{s}\\n", .{if (v) "авжеж" else "ані"}),
        }
    }
};
