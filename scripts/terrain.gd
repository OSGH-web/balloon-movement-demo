extends TileMapLayer

var tile_size = tile_set.tile_size
var window_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var window_height = ProjectSettings.get_setting("display/window/size/viewport_height")
var configured_size = Vector2(window_width, window_height)
var grid_dimensions = configured_size / Vector2(tile_size)

func _ready():
	generate_border()
	generate_sample_terrain()

func generate_border():
	# Fill all four borders of the 16x16 map
	for x in range(grid_dimensions.x):
		# Bottom border (y = 15)
		set_cell(Vector2i(x, grid_dimensions.y - 1), 0, Vector2i(3, 4), 0)
		# Top border (y = 0)
		set_cell(Vector2i(x, 0), 0, Vector2i(3, 4), 0)

	for y in range(1, grid_dimensions.y):  # Skip corners already covered by x loop
		# Left border (x = 0)
		set_cell(Vector2i(0, y), 0, Vector2i(3, 4), 0)
		# Right border (x = 15)
		set_cell(Vector2i(grid_dimensions.x - 1, y), 0, Vector2i(3, 4), 0)

func generate_sample_terrain():
	for x in 13:
		set_cell(Vector2i(x, 7), 0, Vector2i(3, 4), 0)

	set_cell(Vector2i(4, 6), 0, Vector2i(3, 4), 0)
	set_cell(Vector2i(4, 5), 0, Vector2i(3, 4), 0)
