extends CanvasLayer

func _ready() -> void:
	if !get_parent().PROCESS_MODE_PAUSABLE:
		print("warning: parent is not pausable")

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_P) or Input.is_key_pressed(KEY_ESCAPE):
		toggle_pause()
	if Input.is_key_pressed(KEY_A):
		_on_level_select_button_pressed()
	if Input.is_key_pressed(KEY_Q):
		_on_quit_button_pressed()


func toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused

func _on_resume_button_pressed():
	toggle_pause()

func _on_level_select_button_pressed():
	get_tree().paused = false
	return_to_world_select()

func _on_quit_button_pressed():
	get_tree().quit()

func return_to_world_select():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
