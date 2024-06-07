const std = @import("std");

pub const Map = struct {
    compressionlevel: i64 = -1,
    height: i64 = 1,
    hexsidelength: u64 = 0,
    infinite: bool = false,
    orientation: ?[]const u8 = null,
    layers: ?[]Layers = null,
    nextlayerid: u64,
    nextobjectid: u64,
    parallaxoriginx: f64,
    parallaxoriginy: f64,
    properties: ?[]Properties = null,
    renderorder: []const u8 = "right-down",
    staggeraxis: []const u8,
    staggerindex: []const u8,
    tiledversion: []const u8,
    tileheight: u64,
    tilesets: ?[]Tileset = null,
    tilewidth: u64,
    type: []const u8 = "map",
    width: u64,
};

pub const Layers = struct {
    chunks: ?[]Chunk = null,
};

pub const Chunk = struct {
    data: ?[]i64 = null,
};

pub const Tileset = struct {
    columns: i64,
    firstgid: i64,
    grid: Grid = null,
};

pub const Grid = struct {
    height: i64,
    orientation: []const u8 = "orthogonal",
    width: i64,
};

pub const Properties = struct {
    name: []const u8,
    type: []const u8,
    propertytype: []const u8,
    value: []const u8,
};

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
        .compressionlevel = parser.value.object.get("compressionlevel").?.integer,
        .hexsidelength = parser.value.object.get("hexsidelength").?.integer,
        .infinite = parser.value.object.get("infinite").?.bool,
        .orientation = parser.value.object.get("infinite").?.string,
        .layers: parseLayersArray(parser.value.object.get("layers").?.array), //parser for layers array TODO next
        .nextlayerid: u64,
        .nextobjectid: u64,
        .parallaxoriginx: f64,
        .parallaxoriginy: f64,
        .properties: ?*[]Properties = null,
        .renderorder: []const u8 = "right-down",
        .staggeraxis: []const u8,
        .staggerindex: []const u8,
        .tiledversion: []const u8,
        .tileheight: u64,
        .tilesets: ?*[]Tileset = null,
        .tilewidth: u64,
        .type: []const u8 = "map",
        .width: u64,
    };

    return result;
}
