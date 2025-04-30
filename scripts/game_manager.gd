# This GameManager is set to autoload in Project -> Project Settings -> Autoload
# This means that this scene will stay loaded through the entire game. 

extends Control
const SAVE_PATH := "user://level_data.tres"
# Level Data gets populated upon time trial level clear. 
var level_data: LevelData
var curr_level = 0
var lives = 1
# 10k score gives an extra life. You automatically get 1k per level, plus however much fuel you have left over. 
var score = 0
var game_started = false
var time: float = 0.0;
var extraLivesDivisor = 1
var extraLifeFrameDelay = .5 # value in seconds. time between life increases when receiving multiple lives
var level_files = []
var gameStateDisabled = false
# Show a message upon levelCompletion
@onready var background_music = $Background_Music
enum GameModes {ARCADE, TIME_TRIAL}
@onready var gameMode: GameModes
func _ready():
	level_files = load_levels()
	load_data()
	
func load_data() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		level_data = load(SAVE_PATH)
	else:
		level_data = LevelData.new()
		save_data()
		
func save_data() -> void:
	ResourceSaver.save(level_data, SAVE_PATH)

func load_levels():
	var dir = DirAccess.open("res://levels/")
	if dir:
		var level_files_temp = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				level_files_temp.append(file_name)
			file_name = dir.get_next()
		level_files_temp.sort()
		dir.list_dir_end()
		return level_files_temp

		
func reset():
	lives = 3
	score = 0
	time = 0.0
	extraLivesDivisor = 1
	curr_level = 0
	background_music.pitch_scale = 1.03
	get_tree().paused = false
	
func _process(delta):
	if not gameStateDisabled and game_started:
		time += delta

# This is only called for the ARCADE gameMode
func load_next_level():
	if curr_level > 0:
		background_music.pitch_scale = 1.03
		# Prevents bug where level resets if entering endzone when out of fuel. 
		gameStateDisabled = true
		# Freeze to prevent player death after endzone trigger
		await calculateScore() 
		await get_tree().create_timer(1).timeout
	var level_path = "res://levels/%s" % level_files[curr_level]
	curr_level += 1
	time = 0.0
	get_tree().change_scene_to_file(level_path)
	# Must go after changing scene to avoid issues.
	gameStateDisabled = false

# This is only called for the TIME_TRIAL gameMode
func save_time_and_return():
	gameStateDisabled = true
	var level_path = get_tree().current_scene.scene_file_path
	await get_tree().create_timer(1).timeout
	var prev_time = GameManager.level_data.level_times.get(level_path, null)
	# If this is the first level clear
	if prev_time == null or str(time) == "":
		%GameInfo.text = "New Best Time: "+ format_seconds(time)
		%GameInfo.visible = true
		level_data.level_times[level_path] = round(time * 1000) / 1000.0
		save_data()
	else:
		var previous_best_time = level_data.level_times[level_path]
		if time < previous_best_time:
			%GameInfo.text = "New Best Time: "+ format_seconds(time)
			%GameInfo.visible = true
			level_data.level_times[level_path] = round(time * 1000) / 1000.0
			save_data()
	await get_tree().create_timer(1).timeout
	%GameInfo.visible = false
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")
	gameStateDisabled = false

func time_trial_reset():
	game_started = false
	reset()
	get_tree().reload_current_scene()

func _input(event):
	if gameMode == GameModes.TIME_TRIAL:
		if event.is_action_pressed("reset"):
			time_trial_reset()
	# Start the timer upon the first input
		elif event.is_pressed():
			game_started = true
	 # DEV: Go to next level
	elif gameMode == GameModes.ARCADE:
		if event.is_pressed():
			game_started = true
	if event.is_action_pressed("ui_n"):
		if curr_level == len(level_files):
			curr_level = 0
		var level_path = "res://levels/%s" % level_files[curr_level]
		curr_level += 1
		get_tree().change_scene_to_file(level_path)

	# DEV: Go to previous level
	if event.is_action_pressed("ui_p"):
		curr_level -= 1
		var level_path
		if curr_level >= 1:
			level_path = "res://levels/%s" % level_files[curr_level - 1]
		else:
			level_path = "res://levels/%s" % level_files[len(level_files) - 1]
			curr_level = len(level_files)

		get_tree().change_scene_to_file(level_path)

func calculateScore():
	%GameInfo.text = "Level Complete! +1000 Score!"
	%GameInfo.visible = true
	$SmokeWeedEveryday.play()
	await get_tree().create_timer(1).timeout
	score += 1000 # for level clear
	%GameInfo.visible = false
	await scoreCountDown()

	while score > 10000 * extraLivesDivisor:
		await get_tree().create_timer(extraLifeFrameDelay).timeout
		lives += 1
		extraLivesDivisor += 1
		
func scoreCountDown():
	var player = get_player()
	while player.FUEL > 0:
		if player.FUEL <= 5:
			player.FUEL -= 1
			score += 1
		elif player.FUEL >= 2000:
			player.FUEL -= 100
			score += 100
		else:
			player.FUEL -= 5
			score += 5
		await get_tree().process_frame
		
func on_player_died():
	match gameMode:
		GameModes.ARCADE:
			if gameStateDisabled:
				background_music.pitch_scale = 1.03
				return
			lives -= 1
			time = 0.0
			gameStateDisabled = true
			$PlayerDeath.play()
			if lives > 0:
				%GameInfo.text = "YOU DIED! RESETTING LEVEL..."
				%GameInfo.visible = true
				await get_tree().create_timer(1.5).timeout
				background_music.pitch_scale = 1.03
				get_tree().reload_current_scene()
			else:
				if GameManager.level_data.high_score < score:
					%GameInfo.text = "New High Score! " + str(score)
					level_data.high_score = score
					save_data()
				else:
					%GameInfo.text = "GAME OVER! BACK TO LEVEL 1 :) "
				%GameInfo.visible = true
				await get_tree().create_timer(1.5).timeout
				reset()
				load_next_level()
			%GameInfo.visible = false
			gameStateDisabled = false
		GameModes.TIME_TRIAL:
			gameStateDisabled = true
			$PlayerDeath.play()
			await get_tree().create_timer(0.5).timeout
			background_music.pitch_scale = 1.03
			time_trial_reset()
			gameStateDisabled = false

func get_player(): 
	var level = get_tree().get_current_scene()
	return level.get_node("Player")

func format_seconds(time : float) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	var milliseconds := fmod(time, 1) * 100

	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
