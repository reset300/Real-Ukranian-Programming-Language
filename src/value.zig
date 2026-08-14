const std = @import("std");

pub const Value = union(enum) {
    integer: i64,
    string: []const u8,
    boolean: bool,
    nothing: void,

    pub fn writeInline(self: Value) void {
        switch (self) {
            .integer => |value| std.debug.print("{}", .{value}),
            .string => |value| std.debug.print("{s}", .{value}),
            .boolean => |value| std.debug.print("{s}", .{if (value) "авжеж" else "ані"}),
            .nothing => std.debug.print("порожньо", .{}),
        }
    }
};
