const std = @import("std");
const zt = @import("ztileon.zig");

// pub fn main() !void {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     //defer std.debug.assert(gpa.deinit() == .ok);
//
//     defer _ = gpa.deinit();
//
//     const parsed = try zt.readTiledMapJson(gpa.allocator(), "maps/map_output.json");
//
//     const val = parsed;
//     std.debug.print("map:{any}\n", .{val});
// }
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    defer std.debug.assert(gpa.deinit() == .ok);

    var solver = try zt.Solver.init(&allocator, "maps/map_output.json");
    std.debug.print("pased data: {any}\n", .{solver.parsedData.value.object.get("height").?.integer});
    defer solver.deinit();

    // const map = try zt.readTiledMapJson(allocator, "maps/map_output.json");
    // std.debug.print("Map height: {}\n", .{map.height});
    // for (map.layers, 0..) |layer, index| {
    //     std.debug.print("Layer {} height: {}\n", .{ index, layer.height });
    // }
}
