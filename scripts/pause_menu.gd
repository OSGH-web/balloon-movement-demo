extends CanvasLayer

func _ready() -> void:
	if !get_parent().PROCESS_MODE_PAUSABLE:
		print("warning: parent is not pausable")

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_P) or Input.is_key_pressed(KEY_ESCAPE):
		var paused := not get_tree().paused
		get_tree().paused = paused
		visible = paused
	if Input.is_key_pressed(KEY_A):
		if get_tree().paused:
			get_tree().paused = false
			return_to_world_select()
	if Input.is_key_pressed(KEY_Q):
		if get_tree().paused:
			get_tree().quit()

func return_to_world_select():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
