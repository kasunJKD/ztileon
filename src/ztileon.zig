const std = @import("std");

pub const Map = struct {
    compressionlevel: i64 = -1,
    height: i64 = 1,
    hexsidelength: u64 = 0,
    infinite: bool = false,
    orientation: ?[]const u8 = null,
    layers: ?*[]Layers = null,
};

pub const Layers = struct {};

pub fn readTiledMapJson(allocator: std.mem.Allocator, path: []const u8) !Map {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const file_buffer = try allocator.alloc(u8, file_size);
    const data = try std.fs.cwd().readFile(path, file_buffer);
    defer allocator.free(file_buffer);

    //parse json data
    const parser = try std.json.parseFromSlice(std.json.Value, allocator, data, .{ .allocate = .alloc_always });
    defer parser.deinit();

    const result = Map{
        .height = parser.value.object.get("height").?.integer,
    };

    return result;
}
