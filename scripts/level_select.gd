extends Control
class_name LevelSelect

var current_index := 0
var level_files := []

@onready var button_container: GridContainer = %ButtonGrid
@onready var standard_font_theme := load("res://assets/themes/standard_font_theme.theme")

func _ready():
	load_levels()
	create_level_grid()
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

func create_level_grid():
	for child in button_container.get_children():
		child.queue_free()

	var button_scene = preload("res://scenes/UI/level_button.tscn")

	for i in level_files.size():
		var button = button_scene.instantiate() as Button
		button.text = str(i + 1)
		button_container.add_child(button)
		button.pressed.connect(_on_level_selected.bind(i))
		button.focus_entered.connect(_generate_preview.bind(i))
		button.mouse_entered.connect(_generate_preview.bind(i))

func _generate_preview(level_index):
	var file_path = "res://levels/%s" % level_files[level_index]
	$LevelPreview.generate_preview(file_path)	

func _on_level_selected(level_index: int):
	var file_path = "res://levels/%s" % level_files[level_index]
	get_tree().change_scene_to_file(file_path)
