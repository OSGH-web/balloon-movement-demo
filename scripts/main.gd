# Empty main scene for flexibility later on. If we want an intro cutscene/main menu for example.
extends Node
var focused = false;

func _ready():
	GameManager.time = 0.0
	GameManager.reset()
	GameManager.gameMode = GameManager.GameModes.NONE
	%ArcadeButton.grab_focus()
	%Score.text = str(GameManager.level_data.high_score)
	if not GameManager.level_data.arcade_time == null:
		%Time.text = GameManager.format_seconds(GameManager.level_data.arcade_time)

		

func _on_arcade_button_pressed() -> void:
	GameManager.load_first_level()
	GameManager.gameMode = GameManager.GameModes.ARCADE

func _on_trial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")
	GameManager.gameMode = GameManager.GameModes.TIME_TRIAL

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()

func _on_arcade_button_focus_entered() -> void:
	focused = true
	_set_high_score_visibility(true)
	_set_best_time_visibility(true)

func _on_arcade_button_focus_exited() -> void:
	focused = false
	_set_high_score_visibility(false)
	_set_best_time_visibility(false)

func _on_arcade_button_mouse_entered() -> void:
	_set_high_score_visibility(true)
	_set_best_time_visibility(true)

func _on_arcade_button_mouse_exited() -> void:
	_set_high_score_visibility(false)
	_set_best_time_visibility(false)

func _set_high_score_visibility(val):
	if not GameManager.level_data.high_score == 0:
		if focused:
			$ArcadeButton/HighScore.visible = true
		else:
			$ArcadeButton/HighScore.visible = val
	else:
		$ArcadeButton/HighScore.visible = false

func _set_best_time_visibility(val):
	if not GameManager.level_data.arcade_time == null:
		if focused:
			$ArcadeButton/BestTime.visible = true
		else:
			$ArcadeButton/BestTime.visible = val
	else:
		$ArcadeButton/BestTime.visible = false
			


func _on_clear_save_button_pressed() -> void:
	%ConfirmationDialog.popup_centered()


func _on_confirmation_dialog_confirmed() -> void:
	var save_path = "user://level_data.tres"
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		if dir:
			var err = dir.remove("level_data.tres")
			if err == OK:
				print("Save data cleared")
				%SaveClearedDialog.dialog_text = "Save data cleared."
			else:
				print("Failed to delete save data.")
				%SaveClearedDialog.dialog_text = "Failed to delete save data."
		else:
			print("Failed to open user directory,")
			%SaveClearedDialog.dialog_text = "Could not access save directory."
	else:
		print("No save data found.")
		%SaveClearedDialog.dialog_text = "No save data found."
	
	%SaveClearedDialog.popup_centered()
		
