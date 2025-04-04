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

	# Center the level within the viewport
	if !Engine.is_editor_hint():
		var tilemap = $Terrain
		var tile_size = tilemap.tile_set.tile_size

		var map_width_px = width_in_tiles * tile_size.x
		var map_height_px = height_in_tiles * tile_size.y
		var viewport_size = get_viewport().get_visible_rect().size

		# Shift this LevelBase node so that the level is centered
		position = Vector2(
			(viewport_size.x - map_width_px) / 2,
			(viewport_size.y - map_height_px) / 2
		)

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
