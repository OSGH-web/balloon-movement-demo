extends Control
class_name LevelSelect

@export var grid_columns := 5
@export var button_size := Vector2(32, 32)
@export var button_spacing := Vector2(32, 32)

var current_index := 0
var level_files := []

@onready var player_marker := $PlayerMarker
@onready var button_container := $ButtonGrid

@onready var standard_font_theme := load("res://assets/themes/standard_font_theme.theme")

func _ready():
	button_container.position = button_spacing;
	player_marker.offset = button_spacing
	load_levels()
	create_level_grid()
	update_marker_position()

func load_levels():
	var dir = DirAccess.open("res://levels/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("level") && file_name.ends_with(".tscn"):
				level_files.append(file_name)
				file_name = dir.get_next()

				# Alphabetical sorting
				level_files.sort()


func create_level_grid():
	for child in button_container.get_children():
		child.queue_free()

	var button_scene = preload("res://scenes/level_button/level_button.tscn")

	for i in level_files.size():
		var button = button_scene.instantiate() as LevelButton
		button.name = "Level%d" % (i + 1)
		button.level_number = i + 1
		button.get_node("Label").size = button_size
		# Position calculation
		var col = i % grid_columns
		var row = i / grid_columns
		button.position = Vector2(
			col * (button_size.x + button_spacing.x),
			row * (button_size.y + button_spacing.y)
		)

		button_container.add_child(button)

func update_marker_position():
	var current_button = button_container.get_child(current_index)
	player_marker.position = current_button.position


	var file_path = "res://levels/%s" % level_files[current_index]
	create_level_preview(file_path)

func _input(event):
	if event.is_action_pressed("ui_left"):
		try_move(-1, 0)
	elif event.is_action_pressed("ui_right"):
		try_move(1, 0)
	elif event.is_action_pressed("ui_up"):
		try_move(0, -1)
	elif event.is_action_pressed("ui_down"):
		try_move(0, 1)
	elif event.is_action_pressed("ui_a"):
		_on_level_selected(current_index)

func try_move(x: int, y: int):
	var new_index = current_index + x + (y * grid_columns)
	if new_index >= 0 && new_index < level_files.size():
		current_index = new_index
		update_marker_position()

func _on_level_selected(level_index: int):
	var file_path = "res://levels/%s" % level_files[level_index]
	get_tree().change_scene_to_file(file_path)


func create_level_preview(level_path: String):
	var preview_tilemaplayer = get_node("PreviewContainer/PreviewTileMap")
	if not preview_tilemaplayer:
		print(get_tree().current_scene)
		return

	preview_tilemaplayer.clear()

	var level_scene = load(level_path)
	if not level_scene:
		return

	# Instantiate it (but don't add to tree)
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
