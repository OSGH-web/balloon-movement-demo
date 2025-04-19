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

func _ready():
	_update_level_bounds()
	_generate_level_border()
	_update_player_camera()

func _update_level_bounds():
	var tilemap = get_node_or_null("Terrain")
	if !tilemap:
		return

	%TerrainBackground.size.x = width_in_tiles * 24
	%TerrainBackground.size.y = height_in_tiles * 24

func _generate_level_border():
	if Engine.is_editor_hint():
		return; # only run in the game

	$"Terrain".generate_border(width_in_tiles, height_in_tiles)

func _update_player_camera():
	if Engine.is_editor_hint():
		return; # only run in the game
	if $Player:
		$Player._setup_camera_limits(width_in_tiles * 8 * $Player.physics_scale_factor, height_in_tiles * 8 * $Player.physics_scale_factor)
