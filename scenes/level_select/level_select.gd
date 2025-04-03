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

var current_previews = []

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
	clear_existing_previews()

	var level_scene = load(level_path)
	if not level_scene:
		return

	# Instantiate it (but don't add to tree)
	var level_instance = level_scene.instantiate()

	var tilemaplayer = level_instance.find_child("Terrain") as TileMapLayer
	if not tilemaplayer:
		level_instance.free()
		return

	var grid_dimensions = Vector2i(level_instance.width_in_tiles, level_instance.height_in_tiles)

	var preview_tilemaplayer = TileMapLayer.new()
	preview_tilemaplayer.tile_set = tilemaplayer.tile_set

	var used_cells = tilemaplayer.get_used_cells()
	for cell in used_cells:
		var source_id = tilemaplayer.get_cell_source_id(cell)
		var atlas_coords = tilemaplayer.get_cell_atlas_coords(cell)
		var alternative_tile = tilemaplayer.get_cell_alternative_tile(cell)
		preview_tilemaplayer.set_cell(cell, source_id, atlas_coords, alternative_tile)

	# Top and bottom borders
	var border_tile_source_id = 0
	var border_tile_atlas = Vector2i(3, 4)
	for x in range(0, grid_dimensions.x):
		preview_tilemaplayer.set_cell(Vector2i(x, 0), border_tile_source_id, border_tile_atlas, 0)
		preview_tilemaplayer.set_cell(Vector2i(x, grid_dimensions.y - 1), border_tile_source_id, border_tile_atlas, 0)

	# Left and right borders
	for y in range(0, grid_dimensions.y):
		preview_tilemaplayer.set_cell(Vector2i(0, y), border_tile_source_id, border_tile_atlas, 0)
		preview_tilemaplayer.set_cell(Vector2i(grid_dimensions.x-1, y), border_tile_source_id, border_tile_atlas, 0)

	$PreviewContainer.add_child(preview_tilemaplayer)
	$PreviewContainer.scale = Vector2(0.25, 0.25)
	current_previews.append(preview_tilemaplayer)
	level_instance.free()

func clear_existing_previews():
	for preview in current_previews:
		if is_instance_valid(preview) and preview.is_inside_tree():
			preview.get_parent().remove_child(preview)
			preview.queue_free()
	current_previews.clear()
