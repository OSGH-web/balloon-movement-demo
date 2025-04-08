extends TileMapLayer

var tile_size = tile_set.tile_size
var window_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var window_height = ProjectSettings.get_setting("display/window/size/viewport_height")
var configured_size = Vector2(window_width, window_height)

var grid_dimensions 

func _ready():
	var level = get_parent() as Node2D
	grid_dimensions = Vector2i(level.width_in_tiles, level.height_in_tiles)
	generate_border()

func generate_border():
	for x in range(grid_dimensions.x):
		# Bottom border
		set_cell(Vector2i(x, grid_dimensions.y - 1), 1, Vector2i(1, 2), 0)
		# Top border
		set_cell(Vector2i(x, 0), 1, Vector2i(1, 2), 0)

	for y in range(1, grid_dimensions.y):
		# Left border
		set_cell(Vector2i(0, y), 1, Vector2i(1, 2), 0)
		# Right border
		set_cell(Vector2i(grid_dimensions.x - 1, y), 1, Vector2i(1, 2), 0)
