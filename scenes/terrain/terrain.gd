extends TileMapLayer

var tile_size = tile_set.tile_size
var grid_dimensions;

func _ready():
	var level = get_parent() as Node2D
	grid_dimensions = Vector2i(level.width_in_tiles, level.height_in_tiles)

	var level_size = grid_dimensions * tile_size
	var camera = get_viewport().get_camera_2d()

	if camera:
		if level_size == Vector2i(256, 256):
			camera.zoom = Vector2(2.0, 2.0)
		else:
			print("setting offset")
			camera.offset.x = 128

	generate_border()

func generate_border():
	for x in range(grid_dimensions.x):
		# Bottom border
		set_cell(Vector2i(x, grid_dimensions.y - 1), 0, Vector2i(3, 4), 0)
		# Top border
		set_cell(Vector2i(x, 0), 0, Vector2i(3, 4), 0)

	for y in range(1, grid_dimensions.y):
		# Left border
		set_cell(Vector2i(0, y), 0, Vector2i(3, 4), 0)
		# Right border
		set_cell(Vector2i(grid_dimensions.x - 1, y), 0, Vector2i(3, 4), 0)
