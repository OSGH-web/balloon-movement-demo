# Empty main scene for flexibility later on. If we want an intro cutscene/main menu for example.
extends Node

func _ready():
	GameManager.reset()
	%ArcadeButton.grab_focus()
	%Score.text = str(GameManager.level_data.high_score)

func _on_arcade_button_pressed() -> void:
	GameManager.load_next_level()
	GameManager.gameMode = GameManager.GameModes.ARCADE

func _on_trial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")
	GameManager.gameMode = GameManager.GameModes.TIME_TRIAL

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()
