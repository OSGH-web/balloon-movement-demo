extends Control
class_name LevelSelect

var current_index := 0
var level_files := []

@onready var button_container: GridContainer = %ButtonGrid

func _ready():
	level_files = GameManager.load_levels()
	create_level_grid()
	button_container.get_children()[0].grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func create_level_grid():
	for child in button_container.get_children():
		child.queue_free()

	var n_levels = level_files.size()

	var button_scene = preload("res://scenes/UI/level_button.tscn")
	var tinted_style = preload("res://assets/styles/sbf_dark.tres")

	for i in n_levels:
		var button = button_scene.instantiate() as Button
		button.text = str(i + 1)
		button_container.add_child(button)
		button.pressed.connect(_on_level_selected.bind(i))
		button.focus_entered.connect(_focus.bind(i))
		button.mouse_entered.connect(_update_level_info_display.bind(i))
		button.mouse_exited.connect(_mouse_exit)

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
#   - on mouse_exit, the banner displays the level at the cursor_index
var cursor_index = -1
func _focus(level_index):
	cursor_index = level_index
	_update_level_info_display(level_index)

func _mouse_exit():
	_update_level_info_display(cursor_index)

func _on_level_selected(level_index: int):
	var file_path = "res://levels/%s" % level_files[level_index]
	GameManager.time = 0.0
	GameManager.game_started = false
	get_tree().change_scene_to_file(file_path)


func _update_level_info_display(level_index):
	var level_file = level_files[level_index]
	var level_path = "res://levels/%s" % level_file
	var level_scene = load(level_path)
	if not level_scene:
		return

	var level_instance = level_scene.instantiate()
	%LevelName.text = level_instance.level_name
	level_instance.free()
	var time = GameManager.level_data.level_times.get(level_path, null)
	if time == null or str(time) == "":
		%LevelStats.text = "Level Not Complete"
	else:
		%LevelStats.text = GameManager.format_seconds(time)
