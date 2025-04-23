extends CanvasLayer

func _ready() -> void:
	if !get_parent().PROCESS_MODE_PAUSABLE:
		print("warning: parent is not pausable")
	init_mute_audio_button()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			toggle_pause()

func toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused

	if paused:
		%ResumeButton.grab_focus()

func _on_resume_button_pressed():
	toggle_pause()

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

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
