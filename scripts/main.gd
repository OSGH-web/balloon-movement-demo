# Empty main scene for flexibility later on. If we want an intro cutscene/main menu for example.
extends Node

func _input(event):
	if event.is_action_pressed("ui_select"):
		GameManager.reset()
		GameManager.load_next_level()
