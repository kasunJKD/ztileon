const std = @import("std");

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
    //properties: ?[]*Properties = null, // not sure if array or object
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
    //chunks: ?[]Chunk = null, //seems not important
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

pub const Chunk = struct {
    data: ?[]i64 = null,
};

pub const Tileset = struct {
    columns: ?i64,
    firstgid: i64,
    image: []const u8,
    imageheight: i64,
    imagewidth: i64,
    margin: i64,
    name: []const u8,
    // properties: ?[]*Properties = null,    //not sure if this is a object or array
    spaceing: i64,
    tilecount: ?i64,
    tileheight: i64,
    tilewidth: i64,
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
    value: std.json.Value,
};

pub const Solver = struct {
    allocator: *std.mem.Allocator,
    parsedData: std.json.Parsed(std.json.Value),
    result: Map,
    layers: []*Layers,
    //properties: []*Properties,
    tilesets: []*Tileset,

    pub fn init(allocator: *std.mem.Allocator, path: []const u8) !Solver {
        //parsed data
        const parser = try parseJsonFile(allocator, path);
        //layers
        const layersParsedData = try parseLayersArray(allocator, parser.value.object.get("layers").?.array);

        //properties
        // const propertiesParsedData = try parsePropertiesArray(allocator, parser.value.object.get("properties").?.array);

        //tileset
        const tilesetParsedData = try parseTilesetArray(allocator, parser.value.object.get("tilesets").?.array);

        //map
        const result = Map{
            .height = parser.value.object.get("height").?.integer,
            .compressionlevel = if (parser.value.object.get("compressionlevel")) |c| c.integer else null,
            .hexsidelength = if (parser.value.object.get("hexsidelength")) |c| c.integer else null,
            .infinite = if (parser.value.object.get("infinite")) |c| c.bool else null,
            .layers = layersParsedData,
            .nextlayerid = if (parser.value.object.get("nextlayerid")) |c| c.integer else null,
            .nextobjectid = if (parser.value.object.get("nextobjectid")) |c| c.integer else null,
            .parallaxoriginx = if (parser.value.object.get("parallaxoriginx")) |c| c.float else null,
            .parallaxoriginy = if (parser.value.object.get("parallaxoriginy")) |c| c.float else null,
            //.properties = propertiesParsedData,
            .renderorder = if (parser.value.object.get("renderorder")) |c| c.string else null,
            .staggeraxis = if (parser.value.object.get("staggeraxis")) |c| c.string else null,
            .staggerindex = if (parser.value.object.get("staggerindex")) |c| c.string else null,
            .tiledversion = if (parser.value.object.get("tiledversion")) |c| c.string else null,
            .tileheight = parser.value.object.get("tileheight").?.integer,
            .tilesets = tilesetParsedData,
            .tilewidth = parser.value.object.get("tilewidth").?.integer,
            .type = if (parser.value.object.get("type")) |c| c.string else null,
            .width = parser.value.object.get("width").?.integer,
        };

        return .{
            .allocator = allocator,
            .parsedData = parser,
            .layers = layersParsedData,
            .result = result,
            // .properties = propertiesParsedData,
            .tilesets = tilesetParsedData,
        };
    }

    pub fn deinit(self: *Solver) void {
        self.parsedData.deinit();

        for (self.layers) |layer| {
            self.allocator.destroy(layer);
        }
        self.allocator.free(self.layers);
        // self.allocator.free(self.properties);

        for (self.tilesets) |tileset| {
            self.allocator.destroy(tileset);
        }
        self.allocator.free(self.tilesets);
    }
};

pub fn parseJsonFile(allocator: *std.mem.Allocator, path: []const u8) !std.json.Parsed(std.json.Value) {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const file_buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(file_buffer);
    const data = try std.fs.cwd().readFile(path, file_buffer);

    //parse json data
    const parser = try std.json.parseFromSlice(std.json.Value, allocator.*, data, .{ .allocate = .alloc_always });

    return parser;
}

fn parseLayersArray(allocator: *std.mem.Allocator, layersArr: ?std.json.Array) ![]*Layers {
    if (layersArr == null) return undefined;

    const layerCount = layersArr.?.items.len;
    var layers = try allocator.alloc(*Layers, layerCount);

    for (layersArr.?.items, 0..) |item, index| {
        const item_obj = item.object;
        const layer = try allocator.create(Layers);
        layer.*.height = item_obj.get("height").?.integer;
        const dataitems = try parselayer_data(allocator, item_obj.get("data").?.array);
        defer dataitems.deinit();
        layer.*.width = item_obj.get("width").?.integer;
        layer.*.id = if (item_obj.get("id")) |c| c.integer else null;
        layer.*.opacity = item_obj.get("opacity").?.integer;
        layer.*.name = item_obj.get("name").?.string;
        layer.*.visible = item_obj.get("visible").?.bool;
        layer.*.x = item_obj.get("x").?.integer;
        layer.*.y = item_obj.get("y").?.integer;
        layer.*.type = item_obj.get("type").?.string;
        layer.*.data = dataitems.items;

        layers[index] = layer;
    }

    return layers;
}

fn parselayer_data(allocator: *std.mem.Allocator, dataArr: std.json.Array) !std.ArrayList(i64) {
    var result = std.ArrayList(i64).init(allocator.*);
    if (dataArr.items.len > 0) {
        for (dataArr.items) |item| {
            try result.append(item.integer);
        }
        return result;
    } else return undefined;
}

fn parsePropertiesArray(allocator: *std.mem.Allocator, propArr: ?std.json.Array) ![]*Properties {
    const propCount = propArr.?.items.len;
    if (propCount <= 0) {
        return undefined;
    }
    const props = try allocator.alloc(*Properties, propCount);

    for (propArr.?.items, 0..) |item, index| {
        const item_obj = item.object;
        const prop = try allocator.create(Properties);
        prop.*.value = item_obj.get("value").?;
        prop.*.name = item_obj.get("name").?.string;
        prop.*.type = item_obj.get("type").?.string;
        prop.*.propertytype = item_obj.get("propertytype").?.string;

        props[index] = prop;
    }

    return props;
}

fn parseTilesetArray(allocator: *std.mem.Allocator, tileArr: ?std.json.Array) ![]*Tileset {
    const tileCount = tileArr.?.items.len;
    if (tileCount <= 0) {
        return undefined;
    }
    const tiles = try allocator.alloc(*Tileset, tileCount);

    for (tileArr.?.items, 0..) |item, index| {
        const item_obj = item.object;
        const tile = try allocator.create(Tileset);
        tile.*.columns = if (item_obj.get("columns")) |t| t.integer else null;
        tile.*.firstgid = item_obj.get("firstgid").?.integer;
        tile.*.image = item_obj.get("image").?.string;
        tile.*.imageheight = item_obj.get("imageheight").?.integer;
        tile.*.imagewidth = item_obj.get("imagewidth").?.integer;
        tile.*.margin = item_obj.get("margin").?.integer;
        tile.*.name = item_obj.get("name").?.string;
        // tile.*.properties = try parsePropertiesArray(allocator, item_obj.get("properties").?.array);
        tile.*.spaceing = item_obj.get("spacing").?.integer;
        tile.*.tilecount = if (item_obj.get("tilecount")) |t| t.integer else null;
        tile.*.tileheight = item_obj.get("tileheight").?.integer;
        tile.*.tilewidth = item_obj.get("tilewidth").?.integer;

        tiles[index] = tile;
    }

    return tiles;
}
