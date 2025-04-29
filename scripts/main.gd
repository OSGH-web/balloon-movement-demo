# Empty main scene for flexibility later on. If we want an intro cutscene/main menu for example.
extends Node
var focused = false;

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

func _on_arcade_button_focus_entered() -> void:
	focused = true
	_set_high_score_visibility(true)

func _on_arcade_button_focus_exited() -> void:
	focused = false
	_set_high_score_visibility(false)

func _on_arcade_button_mouse_entered() -> void:
	_set_high_score_visibility(true)

func _on_arcade_button_mouse_exited() -> void:
	_set_high_score_visibility(false)

func _set_high_score_visibility(val):
	if focused:
		$ArcadeButton/HighScore.visible = true
	else:
		$ArcadeButton/HighScore.visible = val
