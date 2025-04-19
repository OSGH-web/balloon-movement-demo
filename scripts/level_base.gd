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
		%Background.light_color = background_color_light
		_update_terrain_background_color()

@export var background_color_dark := Color(0, 0, 0):
	set(value):
		background_color_dark = value
		%Background.dark_color = background_color_dark
		_update_terrain_background_color()
		
@export var invert_foreground_colors := false:
	set(value):
		invert_foreground_colors = value
		_update_terrain_background_color()

@export var invert_background_colors := false:
	set(value):
		invert_background_colors = value
		%Background.invert_colors = invert_background_colors

func _enter_tree():
	_update_terrain_background_color()

func _ready():
	_update_level_bounds()
	_update_player_camera()
	_update_terrain_background_color()


func _update_terrain_background_color():
	if invert_foreground_colors:
		$Terrain.background_color = background_color_dark
	else:
		$Terrain.background_color = background_color_light
	
	if width_in_tiles >= 80 and height_in_tiles >= 45:
		$Terrain.background_color = Color(0.0, 0.0, 0.0, 0.0)

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
		
	tilemap.width_in_tiles = width_in_tiles
	tilemap.height_in_tiles = height_in_tiles
