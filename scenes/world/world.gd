extends Node3D

const TILES = {
	"0000": preload("res://scenes/world/tiles/tile_0000.tscn"),
	"0001": preload("res://scenes/world/tiles/tile_0001.tscn"),
	"0010": preload("res://scenes/world/tiles/tile_0010.tscn"),
	"0011": preload("res://scenes/world/tiles/tile_0011.tscn"),
	"0100": preload("res://scenes/world/tiles/tile_0100.tscn"),
	"0101": preload("res://scenes/world/tiles/tile_0101.tscn"),
	"0110": preload("res://scenes/world/tiles/tile_0110.tscn"),
	"0111": preload("res://scenes/world/tiles/tile_0111.tscn"),
	"1000": preload("res://scenes/world/tiles/tile_1000.tscn"),
	"1001": preload("res://scenes/world/tiles/tile_1001.tscn"),
	"1010": preload("res://scenes/world/tiles/tile_1010.tscn"),
	"1011": preload("res://scenes/world/tiles/tile_1011.tscn"),
	"1100": preload("res://scenes/world/tiles/tile_1100.tscn"),
	"1101": preload("res://scenes/world/tiles/tile_1101.tscn"),
	"1110": preload("res://scenes/world/tiles/tile_1110.tscn"),
	"1111": preload("res://scenes/world/tiles/tile_1111.tscn"),
}

const WORLD_WIDTH_TILE = 5
const WORLD_HEIGHT_TILE = 5

const TILE_SIZE = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()

	var world = []
	var queue = []

	for i in range(0, WORLD_HEIGHT_TILE):
		var row = []
		for j in range(0, WORLD_WIDTH_TILE):
			row.push_back(null)
		world.push_back(row)

	var tile_keys = TILES.keys()
	queue.push_front(Vector2i(WORLD_HEIGHT_TILE / 2, WORLD_WIDTH_TILE / 2))

	while queue.size() > 0:
		var tile_id = queue.pop_front()

		var current_tile = get_tile(world, tile_id.x, tile_id.y)

		if current_tile == null and not out_of_bounds(tile_id.x, tile_id.y):
			var left = get_tile(world, tile_id.x, tile_id.y - 1)
			var top = get_tile(world, tile_id.x - 1, tile_id.y)
			var right = get_tile(world, tile_id.x, tile_id.y + 1)
			var bottom = get_tile(world, tile_id.x + 1, tile_id.y)

			var allowed_tiles = tile_keys
			if left != null:
				var filter_tiles = filter_joing_tiles(left, 3)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			elif top == null and out_of_bounds(tile_id.x, tile_id.y - 1):
				var filter_tiles = filter_joing_tiles("0000", 3)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			else:
				queue.push_back(Vector2i(tile_id.x, tile_id.y - 1))

			if top != null:
				var filter_tiles = filter_joing_tiles(top, 0)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			elif top == null and out_of_bounds(tile_id.x - 1, tile_id.y):
				var filter_tiles = filter_joing_tiles("0000", 0)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			else:
				queue.push_back(Vector2i(tile_id.x - 1, tile_id.y))

			if right != null:
				var filter_tiles = filter_joing_tiles(right, 1)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			elif top == null and out_of_bounds(tile_id.x, tile_id.y + 1):
				var filter_tiles = filter_joing_tiles("0000", 1)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			else:
				queue.push_back(Vector2i(tile_id.x, tile_id.y + 1))

			if bottom != null:
				var filter_tiles = filter_joing_tiles(bottom, 2)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			elif top == null and out_of_bounds(tile_id.x + 1, tile_id.y):
				var filter_tiles = filter_joing_tiles("0000", 2)
				allowed_tiles = ArrayUtil.intersect_i(allowed_tiles, filter_tiles)
			else:
				queue.push_back(Vector2i(tile_id.x + 1, tile_id.y))

			world[tile_id.x][tile_id.y] = allowed_tiles[random.randi() % allowed_tiles.size()]

	for i in range(0, WORLD_HEIGHT_TILE):
		for j in range(0, WORLD_WIDTH_TILE):
			var tile = TILES[world[i][j]].instantiate()
			tile.position.x = j * TILE_SIZE - WORLD_WIDTH_TILE * TILE_SIZE / 2
			tile.position.z = i * TILE_SIZE - WORLD_HEIGHT_TILE * TILE_SIZE / 2
			tile.get_node("StaticBody3D").add_to_group("ground")
			tile.get_node("Sprite3D").render_priority = 0
			tile.scale = Vector3(2.01, 1, 2.01)
			add_child(tile)


func filter_joing_tiles(existing_tile, a):
	return TILES.keys().filter(func(tile): return tile[a] == existing_tile[(a + 2) % 4])


func get_tile(world, x, y):
	if out_of_bounds(x, y):
		return null

	return world[x][y]


func out_of_bounds(x, y):
	if x >= WORLD_HEIGHT_TILE or y >= WORLD_WIDTH_TILE or x < 0 or y < 0:
		return true
	return false
