extends Control
class_name LevelPreview

@export var wall_tile_atlas := Vector2i(6, 0)
@export var player_tile_atlas := Vector2i(2, 0)
@export var end_zone_tile := Vector2i(3, 0)
@export var powerup_tile := Vector2i(4, 0)

@onready var preview_tilemaplayer: TileMapLayer = $PreviewTileMap

func generate_preview(level_path: String):
	preview_tilemaplayer.clear()

	var level_scene = load(level_path)
	if not level_scene:
		return

	var level_instance = level_scene.instantiate()

	# get the tilemap from the level we're hovering over
	var tilemaplayer = level_instance.find_child("Terrain") as TileMapLayer
	if not tilemaplayer:
		level_instance.free()
		return

	var level_dimensions = Vector2i(level_instance.width_in_tiles, level_instance.height_in_tiles)

	var wall_tile_atlas = Vector2i(6, 0)
	var player_tile_atlas = Vector2i(2, 0)

	for cell in tilemaplayer.get_used_cells():
		var alternative_tile = tilemaplayer.get_cell_alternative_tile(cell)
		preview_tilemaplayer.set_cell(cell, 0, wall_tile_atlas, alternative_tile)

	# Draw player position
	var player_node = level_instance.find_child("Player", true, false)
	if player_node and player_node is CharacterBody2D:
		var player_tile_offset = Vector2i(2, 4)
		var player_tile_pos = tilemaplayer.local_to_map(player_node.global_position) + player_tile_offset
		preview_tilemaplayer.set_cell(player_tile_pos, 0, Vector2i(2, 0), 0)

	# Draw EndZone area
	var end_zone = level_instance.find_child("EndZone", true, false)
	if end_zone:
		# Get collision shape and calculate coverage
		var end_zone_center = end_zone.global_position
		var half_size = end_zone.size / 2
		var start_pos = end_zone_center - half_size
		var end_pos = end_zone_center + half_size

		var start_tile = tilemaplayer.local_to_map(start_pos)
		var end_tile = tilemaplayer.local_to_map(end_pos)

		# Draw all tiles in the EndZone area
		for x in range(start_tile.x, end_tile.x):
			for y in range(start_tile.y, end_tile.y):
				preview_tilemaplayer.set_cell(Vector2i(x, y), 0, Vector2i(3, 0), 0)

	# Draw Powerup (GasCan) areas
	var powerups = level_instance.find_children("*", "GasCan", true, false)
	print(powerups)
	for powerup in powerups:
		var pos = powerup.global_position
		var tile_position = tilemaplayer.local_to_map(pos)
		preview_tilemaplayer.set_cell(tile_position, 0, Vector2i(4, 0), 0)

	level_instance.free()
	# Draw Top and bottom borders
	for x in range(0, level_dimensions.x):
		preview_tilemaplayer.set_cell(Vector2i(x, 0), 0, wall_tile_atlas, 0)
		preview_tilemaplayer.set_cell(Vector2i(x, level_dimensions.y - 1), 0, wall_tile_atlas, 0)

	# Draw Left and right borders
	for y in range(0, level_dimensions.y):
		preview_tilemaplayer.set_cell(Vector2i(0, y), 0, wall_tile_atlas, 0)
		preview_tilemaplayer.set_cell(Vector2i(level_dimensions.x-1, y), 0, wall_tile_atlas, 0)
