extends Control
class_name LevelSelect

var current_index := 0
var level_files := []

@onready var button_container: GridContainer = %ButtonGrid
@onready var standard_font_theme := load("res://assets/themes/standard_font_theme.theme")

func _ready():
	load_levels()
	create_level_grid()
	_update_world_info_display()
	button_container.get_children()[0].grab_focus()

func load_levels():
	var dir = DirAccess.open("res://levels/")
	if dir:
		level_files.clear()
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("level") && file_name.ends_with(".tscn"):
				level_files.append(file_name)
			file_name = dir.get_next()
		level_files.sort()


func get_completion_percentage() -> float:
	var count := 0
	for level_path in level_files:
		if SaveManager.is_level_completed(level_path):
			count += 1

	return (count / float(level_files.size())) * 100

func create_level_grid():
	for child in button_container.get_children():
		child.queue_free()

	var n_levels = level_files.size()

	var button_scene = preload("res://scenes/UI/level_button.tscn")
	var tinted_style = preload("res://assets/styles/button_tinted.tres")

	for i in n_levels:
		var button = button_scene.instantiate() as Button
		button.text = str(i + 1)
		button_container.add_child(button)
		button.pressed.connect(_on_level_selected.bind(i))
		button.focus_entered.connect(_focus.bind(i))
		button.mouse_entered.connect(_generate_preview.bind(i))
		button.mouse_exited.connect(_mouse_exit.bind(i))

		# tint the completed levels
		if SaveManager.is_level_completed(level_files[i]):
			button.add_theme_stylebox_override("normal", tinted_style)
			button.add_theme_stylebox_override("hover", tinted_style)

	# update focus neighbors to allow for horizontal wrapping
	for i in n_levels:
		var neighbor_left_idx = (i - 1) % n_levels
		var neighbor_right_idx = (i + 1) % n_levels

		var button = button_container.get_child(i)
		var neighbor_left = button_container.get_child(neighbor_left_idx)
		var neighbor_right = button_container.get_child(neighbor_right_idx)
		button.focus_neighbor_left = neighbor_left.get_path()
		button.focus_neighbor_right = neighbor_right.get_path()

# steal back cursor focus after hover
#   - cursor_index is updated on arrow key movement.
#   - cursor_index is not updated on mouse_entered.
#   - on mouse_exit, the preview displays the level at the cursor_index
var cursor_index = -1
func _focus(level_index):
	cursor_index = level_index
	_generate_preview(level_index)

func _mouse_exit(level_index):
	_generate_preview(cursor_index)

func _generate_preview(level_index):
	var file_path = "res://levels/%s" % level_files[level_index]
	$LevelPreview.generate_preview(file_path)
	_update_level_info_display(level_index)

func _on_level_selected(level_index: int):
	var file_path = "res://levels/%s" % level_files[level_index]
	get_tree().change_scene_to_file(file_path)

func _update_world_info_display():
	var completion_percentage = get_completion_percentage()
	%WorldCompletion.text = "Completion: %.0f" % completion_percentage + "%"

func _update_level_info_display(level_index):
	var level_file = level_files[level_index]
	var level_path = "res://levels/%s" % level_file
	var level_scene = load(level_path)
	if not level_scene:
		return

	var level_instance = level_scene.instantiate()
	%LevelName.text = level_instance.level_name
	level_instance.free()

	%LevelStats.text = "Completed" if SaveManager.is_level_completed(level_file) else "Not Completed"
	%LevelNumber.text = "1-" + str(level_index + 1)
