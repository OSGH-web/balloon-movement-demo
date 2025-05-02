# Move HUD from levelBase to GameManager
extends CanvasLayer

@export var player: CharacterBody2D

func _ready():
	if GameManager.gameMode == GameManager.GameModes.TIME_TRIAL:
		%Lives.visible = false
		%Score.visible = false
		%Fuel.position.y = 25
		%Timer.position.y = 25
	elif GameManager.gameMode == GameManager.GameModes.ARCADE:
		display_level_name()
			
func _process(delta: float) -> void:
	if not player:
		return
	var fuel_amount = max(0, int(player.FUEL))
	%Fuel.text = "Fuel: %d" % fuel_amount
	if GameManager.gameMode == GameManager.GameModes.ARCADE:
		%Lives.text = "Lives: %d" % GameManager.lives
		%Score.text = "Score: %d" % GameManager.score
	%Timer.text = GameManager.format_seconds(GameManager.time)
	
func display_level_name():
	if GameManager.gameMode == GameManager.GameModes.ARCADE:
		if not GameManager.curr_level == len(GameManager.level_files):
			var level_files  = GameManager.load_levels(true)
			var level_file = level_files[GameManager.curr_level - 1]
			var level_path = "res://levels/%s" % level_file
			var level_scene = load(level_path)
			if not level_scene:
				return
			var level_instance = level_scene.instantiate()
			%LevelName.text = level_instance.level_name
			await _fade_out_and_hide_label()
		
func _fade_out_and_hide_label(duration: float = 5.0) -> void:
	var label := %LevelName
	label.visible = true
	var time := 0.0
	var start_alpha := 1.0
	var end_alpha := 0.0
	while time < duration:
		var t := time / duration
		var alpha: float = lerp(start_alpha, end_alpha, t)
		var color: Color = label.modulate
		color.a = alpha
		label.modulate = color
		await get_tree().process_frame
		time += get_process_delta_time()
	# Ensure it's fully invisible
	var final_color: Color = label.modulate
	final_color.a = 0.0
	label.modulate = final_color
	# Optional delay or immediate reset
	await get_tree().process_frame  # Ensures visuals update before hiding
	# Restore opacity for next use, but hide the node
	final_color.a = 1.0
	label.modulate = final_color
	label.visible = false
