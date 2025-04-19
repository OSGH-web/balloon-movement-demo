@tool
extends TileMapLayer

var tile_size = tile_set.tile_size
var window_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var window_height = ProjectSettings.get_setting("display/window/size/viewport_height")
var configured_size = Vector2(window_width, window_height)

@export var background_color := Color(1.0, 1.0, 1.0, 1.0):
	set(value):
		background_color = value
		_update_background_color()

@export var width_in_tiles := 32:
	set(value):
		width_in_tiles = value
		_update_level_bounds()

@export var height_in_tiles := 64:
	set(value):
		height_in_tiles = value
		_update_level_bounds()

@onready var level_background = $LevelBackground

func _ready():
	generate_border()

func generate_border():
	for x in range(width_in_tiles):
		# Bottom border
		set_cell(Vector2i(x, height_in_tiles - 1), 1, Vector2i(1, 2), 0)
		# Top border
		set_cell(Vector2i(x, 0), 1, Vector2i(1, 2), 0)

	for y in range(1, height_in_tiles):
		# Left border
		set_cell(Vector2i(0, y), 1, Vector2i(1, 2), 0)
		# Right border
		set_cell(Vector2i(width_in_tiles - 1, y), 1, Vector2i(1, 2), 0)

func _update_background_color():
	if not level_background:
		return

	level_background.color = background_color

func _update_level_bounds():
	if not level_background:
		return

	level_background.size = Vector2(
		width_in_tiles * tile_set.tile_size.x,
		height_in_tiles * tile_set.tile_size.y
	)
