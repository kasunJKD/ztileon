const std = @import("std");
const zt = @import("ztileon.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    defer std.debug.assert(gpa.deinit() == .ok);

    var solver = try zt.Solver.init(&allocator, "maps/map_output.json");
    std.debug.print("pased data: {any}\n", .{solver.parsedData.value.object.get("height").?.integer});
    std.debug.print("result {}\n", .{solver.result});
    defer solver.deinit();
}
