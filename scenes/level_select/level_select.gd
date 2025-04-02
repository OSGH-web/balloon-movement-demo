extends Control
class_name LevelSelect

@export var grid_columns := 4
@export var button_size := Vector2(24, 24)
@export var button_spacing := Vector2(24, 24)

var current_index := 0
var level_numbers := []

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
				var level_num = file_name.trim_prefix("level").trim_suffix(".tscn")
				if level_num.is_valid_int():
					level_numbers.append(level_num.to_int())
			file_name = dir.get_next()
		level_numbers.sort()


func create_level_grid():
	# Clear existing buttons
	for child in button_container.get_children():
		child.queue_free()
	
	var button_scene = preload("res://scenes/level_button/level_button.tscn")
	
	for i in level_numbers.size():
		var button = button_scene.instantiate() as LevelButton
		button.name = "Level%d" % (i + 1)
		button.level_number = i + 1
		button.custom_minimum_size = button_size
		
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
		_on_level_selected(current_index + 1)

func try_move(x: int, y: int):
	var new_index = current_index + x + (y * grid_columns)
	if new_index >= 0 && new_index < level_numbers.size():
		current_index = new_index
		update_marker_position()

func _on_level_selected(level_number: int):
	print("on_level_select")
	get_tree().change_scene_to_file("res://levels/level%d.tscn" % level_number)
