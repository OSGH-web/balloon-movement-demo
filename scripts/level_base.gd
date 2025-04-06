@tool
extends Node2D

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
	if $Player:
		$Player._setup_camera_limits(width_in_tiles * 8, height_in_tiles * 8)

func _update_level_bounds():
	if !Engine.is_editor_hint():
		return  # Only run in the editor

	# Clear existing ColorRect (if any)
	for child in get_children():
		if child is ColorRect:
			child.queue_free()

	# Create new bounds overlay
	var tilemap = $Terrain
	if !tilemap or !tilemap.tile_set:
		return  # Safety check

	var rect = ColorRect.new()
	rect.color = Color(1, 0, 0, 0.1)
	rect.size = Vector2(
		width_in_tiles * tilemap.tile_set.tile_size.x,
		height_in_tiles * tilemap.tile_set.tile_size.y
	)
	add_child(rect)
	rect.z_index = 1  # Render behind tiles
