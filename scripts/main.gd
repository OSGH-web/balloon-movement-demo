# Empty main scene for flexibility later on. If we want an intro cutscene/main menu for example.
extends Node

func _ready():
	%ArcadeButton.grab_focus()

func _on_arcade_button_pressed() -> void:
	GameManager.reset()
	GameManager.load_next_level()

func _on_trial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")
