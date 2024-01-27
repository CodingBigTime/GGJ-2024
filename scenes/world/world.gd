extends Node3D

const TILE_RULES = {1: [2, 3, 4], 2: [1, 3, 4], 3: [1, 2, 4], 4: [1, 2, 3]}

const TILE_SCENES = {
	1: preload("res://scenes/world/tiles/tile1.tscn"),
	2: preload("res://scenes/world/tiles/tile2.tscn"),
	3: preload("res://scenes/world/tiles/tile3.tscn"),
	4: preload("res://scenes/world/tiles/tile4.tscn"),
}

const WORLD_WIDTH_TILE = 50
const WORLD_HEIGHT_TILE = 50


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

	var tiles_rules_keys = TILE_RULES.keys()
	queue.push_front(Vector2i(WORLD_HEIGHT_TILE / 2, WORLD_WIDTH_TILE / 2))

	while queue.size() > 0:
		var tile_id = queue.pop_front()

		var current_tile = get_tile(world, tile_id.x, tile_id.y)

		if current_tile == null and not out_of_bounds(tile_id.x, tile_id.y):
			var left = get_tile(world, tile_id.x, tile_id.y - 1)
			var top = get_tile(world, tile_id.x - 1, tile_id.y)
			var right = get_tile(world, tile_id.x, tile_id.y + 1)
			var bottom = get_tile(world, tile_id.x + 1, tile_id.y)

			var allowed_tiles = tiles_rules_keys
			if left != null:
				allowed_tiles = ArrayUtil.intersectI(allowed_tiles, TILE_RULES[left])
			else:
				queue.push_back(Vector2i(tile_id.x, tile_id.y - 1))

			if top != null:
				allowed_tiles = ArrayUtil.intersectI(allowed_tiles, TILE_RULES[top])
			else:
				queue.push_back(Vector2i(tile_id.x - 1, tile_id.y))

			if right != null:
				allowed_tiles = ArrayUtil.intersectI(allowed_tiles, TILE_RULES[right])
			else:
				queue.push_back(Vector2i(tile_id.x, tile_id.y + 1))

			if bottom != null:
				allowed_tiles = ArrayUtil.intersectI(allowed_tiles, TILE_RULES[bottom])
			else:
				queue.push_back(Vector2i(tile_id.x + 1, tile_id.y))

			world[tile_id.x][tile_id.y] = allowed_tiles[random.randi() % allowed_tiles.size()]

	for i in range(0, WORLD_HEIGHT_TILE):
		for j in range(0, WORLD_WIDTH_TILE):
			var tile = TILE_SCENES[world[i][j]].instantiate()
			tile.position.x = i * 5
			tile.position.z = j * 5
			add_child(tile)


func get_tile(world, x, y):
	if out_of_bounds(x, y):
		return null

	return world[x][y]


func out_of_bounds(x, y):
	if x >= WORLD_HEIGHT_TILE or y >= WORLD_WIDTH_TILE or x < 0 or y < 0:
		return true
	return false
