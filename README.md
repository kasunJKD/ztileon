# **Ztileon** <sub>_Json parser for Tiled_ </sub>
`version v1.0 - zig version 12.0`

> **Reference documentation for _[Tiled](https://doc.mapeditor.org/en/stable/reference/json-map-format/#map)_.**

---
> [!TIP]
> how to use on a project.
```zig
const std = @import("std");
const zt = @import("ztileon.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    defer std.debug.assert(gpa.deinit() == .ok);

    //solver can access below objects
    const solver = try zt.Solver.init(&allocator, "maps/map_output.json");

    defer solver.deinit();
}
```

```zig

//current accessible objects

pub const Map = struct {
    compressionlevel: ?i64,
    height: i64 = 1,
    hexsidelength: ?i64,
    infinite: ?bool = false,
    layers: []*Layers,
    nextlayerid: ?i64,
    nextobjectid: ?i64,
    parallaxoriginx: ?f64,
    parallaxoriginy: ?f64,
    renderorder: ?[]const u8 = null,
    staggeraxis: ?[]const u8 = null,
    staggerindex: ?[]const u8 = null,
    tiledversion: ?[]const u8 = null,
    tileheight: i64,
    tilesets: []*Tileset,
    tilewidth: i64,
    type: ?[]const u8 = "map",
    width: i64,
};

pub const Layers = struct {
    data: []i64,
    height: i64,
    width: i64,
    id: ?i64,
    opacity: i64,
    name: []const u8,
    visible: bool,
    x: i64,
    y: i64,
    type: []const u8,
};

pub const Tileset = struct {
    columns: ?i64,
    firstgid: i64,
    image: []const u8,
    imageheight: i64,
    imagewidth: i64,
    margin: i64,
    name: []const u8,
    spaceing: i64,
    tilecount: ?i64,
    tileheight: i64,
    tilewidth: i64,
};
```
---
TODO
- [ ] add chunks
- [ ] add object
- [ ] add point
- [ ] add other data arrays
- [ ] add properties (it is mentioned as a array on documentation but output gives a object... occuring issue)

