@tool
extends Node2D

@export var level_name := ""

@export var width_in_tiles := 32:
	set(value):
		width_in_tiles = value
		_update_level_bounds()  # Refresh when changed

@export var height_in_tiles := 64:
	set(value):
		height_in_tiles = value
		_update_level_bounds()  # Refresh when changed
		
@export var background_color_light := Color(1, 1, 1):
	set(value):
		background_color_light = value
		_update_background_color()
@export var background_color_dark := Color(0, 0, 0):
	set(value):
		background_color_dark = value
		_update_background_color()

		
@export var invert_foreground_colors := false:
	set(value):
		invert_foreground_colors = value
		_update_background_color()
@export var invert_background_colors := false:
	set(value):
		invert_background_colors = value
		_update_background_color()

var level_background: ColorRect;

func _enter_tree():
	_update_background_color()

func _ready():
	_update_level_bounds()
	_update_player_camera()
	_update_background_color()


func _update_background_color():
	%Background.dark_color = background_color_dark
	%Background.light_color = background_color_light
	%Background.invert_colors = invert_background_colors

	if not level_background:
		return
		
	level_background.color = background_color_light
	if invert_foreground_colors:
		level_background.color = background_color_dark
	
	if width_in_tiles >= 80 and height_in_tiles >= 45:
		level_background.visible = false

func _update_player_camera():
	if Engine.is_editor_hint():
		return; # only run in the game
	if $Player:
		$Player._setup_camera_limits(width_in_tiles * 8 * $Player.physics_scale_factor, height_in_tiles * 8 * $Player.physics_scale_factor)

func _update_level_bounds():
	# Create new bounds overlay
	var tilemap = get_node_or_null("Terrain")
	if !tilemap:
		return
	
		# Clear existing ColorRect (if any)
	for child in tilemap.get_children():
		if child is ColorRect:
			child.queue_free()

	level_background = ColorRect.new()
	level_background.color = background_color_light
	level_background.size = Vector2(
		width_in_tiles * tilemap.tile_set.tile_size.x,
		height_in_tiles * tilemap.tile_set.tile_size.y
	)
	tilemap.add_child(level_background)
	level_background.z_index = -1  # Render behind tiles
