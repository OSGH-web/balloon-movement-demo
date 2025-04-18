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
		
@export var x_scale := 48:
	set(value):
		x_scale = value
		_update_background_color()
		
@export var y_scale := 48:
	set(value):
		y_scale = value
		_update_background_color()
		
@export var invert_foreground_colors := false:
	set(value):
		invert_foreground_colors = value
		_update_background_color()
@export var invert_background_colors := false:
	set(value):
		invert_background_colors = value
		_update_background_color()
				


func _enter_tree():
	_update_background_color()

func _ready():
	_update_level_bounds()
	_update_player_camera()
	_update_background_color()


func _update_background_color():
	if not %TextureRect:
		return
		
	if invert_background_colors:
		%TextureRect.material.set("shader_parameter/light_color", background_color_dark)
		%TextureRect.material.set("shader_parameter/dark_color", background_color_light)
	else:
		%TextureRect.material.set("shader_parameter/light_color", background_color_light)
		%TextureRect.material.set("shader_parameter/dark_color", background_color_dark)
	%TextureRect.material.set("shader_parameter/x_scale", x_scale)
	%TextureRect.material.set("shader_parameter/y_scale", y_scale)


	if invert_foreground_colors:
		%Background.material.set("shader_parameter/light_color", background_color_dark)
		%Background.material.set("shader_parameter/dark_color", background_color_light)
	else:
		%Background.material.set("shader_parameter/light_color", background_color_light)
		%Background.material.set("shader_parameter/dark_color", background_color_dark)
	%Background.material.set("shader_parameter/x_scale", x_scale)
	%Background.material.set("shader_parameter/y_scale", y_scale)
	%Background.size = Vector2(
		width_in_tiles * $Terrain.tile_set.tile_size.x,
		height_in_tiles * $Terrain.tile_set.tile_size.y
	)
	%Background.position = $Terrain.position

func _update_player_camera():
	if Engine.is_editor_hint():
		return; # only run in the game
	if $Player:
		$Player._setup_camera_limits(width_in_tiles * 8 * $Player.physics_scale_factor, height_in_tiles * 8 * $Player.physics_scale_factor)

func _update_level_bounds():
	if !Engine.is_editor_hint():
		return  # Only run in the editor

	# Clear existing ColorRect (if any)
	for child in get_children():
		if child is ColorRect:
			child.queue_free()

	# Create new bounds overlay
	var tilemap = get_node_or_null("Terrain")
	if !tilemap:
		return

	var rect = ColorRect.new()
	rect.color = Color(1, 0, 0, 0.1)
	rect.size = Vector2(
		width_in_tiles * tilemap.tile_set.tile_size.x,
		height_in_tiles * tilemap.tile_set.tile_size.y
	)
	add_child(rect)
	rect.z_index = 1  # Render behind tiles
