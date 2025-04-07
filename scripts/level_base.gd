@tool
class_name LevelBase
extends Node2D

@export var width_in_tiles := 32:
	set(value):
		width_in_tiles = value
		_update_level_bounds()  # Refresh when changed

@export var height_in_tiles := 64:
	set(value):
		height_in_tiles = value
		_update_level_bounds()  # Refresh when changed

func getMapSizePx() -> Vector2:
	var tilemap: TileMapLayer = $Terrain
	var tile_size_px = tilemap.tile_set.tile_size
	var map_size_tiles = Vector2i(width_in_tiles, height_in_tiles)
	return map_size_tiles * tile_size_px

func _ready():
	_update_level_bounds()

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
