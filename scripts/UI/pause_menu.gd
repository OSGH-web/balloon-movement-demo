extends CanvasLayer

func _ready() -> void:
	if !get_parent().PROCESS_MODE_PAUSABLE:
		print("warning: parent is not pausable")
	init_mute_audio_button()

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		toggle_pause()

func toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused

	if paused:
		%ResumeButton.grab_focus()

func _on_resume_button_pressed():
	toggle_pause()

func return_to_world_select():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_level_select_button_pressed():
	get_tree().paused = false
	return_to_world_select()

func _on_quit_button_pressed():
	get_tree().quit()

func init_mute_audio_button() -> void:
	var master_bus_idx := AudioServer.get_bus_index("Master")
	var muted := AudioServer.is_bus_mute(master_bus_idx)
	%MuteAudioButton.text = "Unmute Audio" if muted else "Mute Audio"

func toggle_master_audio_mute() -> void:
	var master_bus_idx := AudioServer.get_bus_index("Master")
	var muted := not AudioServer.is_bus_mute(master_bus_idx)
	AudioServer.set_bus_mute(master_bus_idx, muted)
	%MuteAudioButton.text = "Unmute Audio" if muted else "Mute Audio"

func _on_mute_audio_button_pressed() -> void:
	toggle_master_audio_mute()
