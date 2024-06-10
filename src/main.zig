const std = @import("std");
const zt = @import("ztileon.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer std.debug.assert(gpa.deinit() == .ok);

    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const parsed = try zt.readTiledMapJson(allocator, "maps/map_output.json");

    const val = parsed.height;
    std.debug.print("map:{any}\n", .{val});
}
