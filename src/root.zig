const std = @import("std");
const testing = std.testing;
const zt = @import("ztileon.zig");

test "basictestMain" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const parsed = try zt.readTiledMapJson(allocator, "maps/map_output.json");

    //const val = parsed.height;
    std.debug.print("map:{any}\n", .{parsed});
}
