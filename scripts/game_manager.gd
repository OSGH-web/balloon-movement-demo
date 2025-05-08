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
var endOfLevelDelay = 1.0
var extraLifeFrameDelay = .25 # value in seconds. time between life increases when receiving multiple lives
var scoreCountdownRate = 200
var level_files = []
var gameStateDisabled = false
# Show a message upon levelCompletion
@onready var background_music = $Background_Music
# gameMode NONE prevents timer from being started due to input on the title screen.
enum GameModes {NONE, ARCADE, TIME_TRIAL}
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

func load_levels(time_trials=false):
	var filename_matcher = "*.tscn"
	if time_trials:
		filename_matcher = "1-??_*.tscn"

	var dir = DirAccess.open("res://levels/")
	if dir:
		var level_files_temp = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# ensure the file name is good when project is exported
			file_name = file_name.replace('.remap', '')

			if file_name.match(filename_matcher):
				level_files_temp.append(file_name)
			file_name = dir.get_next()
		level_files_temp.sort()
		dir.list_dir_end()
		return level_files_temp

func reset():
	lives = 4
	score = 0
	extraLivesDivisor = 1
	curr_level = 0
	background_music.pitch_scale = 1.03
	game_started = false
	get_tree().paused = false
	endOfLevelDelay = 1.0
	extraLifeFrameDelay = 0.25
	scoreCountdownRate = 200
	
func time_trial_reset():
	time = 0.0
	reset()
	get_tree().reload_current_scene()

func _process(delta):
	if not gameStateDisabled and game_started:
		time += 1000 * delta

func load_first_level():
	curr_level += 1
	get_tree().change_scene_to_file("res://levels/%s" % level_files[0])

# This is only called for the ARCADE gameMode
func load_next_level():
	var level_path

	background_music.pitch_scale = 1.03
	gameStateDisabled = true
	if not curr_level == len(level_files):
		await _calculate_score()
		await _lives_count_up()
		await get_tree().create_timer(endOfLevelDelay).timeout

		level_path = "res://levels/%s" % level_files[curr_level]
		curr_level += 1
	else:
		curr_level = 0
		await _calculate_score("You Win!")

		if GameManager.level_data.high_score < score:
			await _display_info_duration("New High Score! " + str(score), 2.5)
			level_data.high_score = score
			save_data()
		if GameManager.level_data.arcade_time == null:
			await _display_info_duration("New Best Time! " + format_milliseconds(floori(time)), 2.5)
			level_data.arcade_time = time
			save_data()
		elif GameManager.level_data.arcade_time > time:
			await _display_info_duration("New Best Time! " + format_milliseconds(floori(time)), 2.5)
			level_data.arcade_time = time
			save_data()

		await _display_info_duration("Thanks for Playing!", 2.5)
		
		level_path = "res://scenes/main.tscn"
	game_started = false
	get_tree().change_scene_to_file(level_path)
	
	
	# Must go after changing scene to avoid issues.
	gameStateDisabled = false
	


func _display_info_duration(text: String, duration: float):
	%GameInfo.text = text
	%GameInfo.visible = true
	await get_tree().create_timer(duration).timeout
	%GameInfo.visible = false

# This is only called for the TIME_TRIAL gameMode
func save_time_and_return():
	gameStateDisabled = true
	var level_path = get_tree().current_scene.scene_file_path
	await get_tree().create_timer(1).timeout
	var prev_time = GameManager.level_data.level_times.get(level_path, null)
	var recorded_time: int = floori(time)

	# If this is the first level clear, or if the recorded time has been beaten
	# save the new time
	if prev_time == null or str(prev_time) == "" or recorded_time < prev_time:
		await _display_info_duration("New Best Time: "+ format_milliseconds(recorded_time), 1)
		level_data.level_times[level_path] = recorded_time
		save_data()
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")
	background_music.pitch_scale = 1.03
	gameStateDisabled = false

func _input(event):
	if gameMode == GameModes.TIME_TRIAL:
		if event.is_action_pressed("reset"):
			time_trial_reset()
	if gameMode == GameModes.ARCADE or gameMode == GameModes.TIME_TRIAL:
		# start timer upon first movement input each level
		if Input.is_action_pressed("ui_left") \
		or Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_up") \
		or Input.is_action_pressed("ui_down"):
			game_started = true

	if gameMode == GameModes.ARCADE and gameStateDisabled:
		if Input.is_action_just_pressed("ui_accept"):
			endOfLevelDelay = 0.125
			extraLifeFrameDelay = .0625
			scoreCountdownRate = 1000


func _calculate_score(text="Level Complete! +1000 Score!"):
	#$SmokeWeedEveryday.play() TODO: Replace this with different sound effect.
	await _display_info_duration(text, 1.5)
	score += 1000 # for level clear
	await get_tree().create_timer(0.4).timeout
	await _score_count_down()

func _lives_count_up():
	while score > 10000 * extraLivesDivisor:
		await get_tree().create_timer(extraLifeFrameDelay).timeout
		lives += 1
		extraLivesDivisor += 1
	
func _score_count_down():
	var player = get_player()
	while int(player.FUEL) > 0:
		if int(player.FUEL) == 1:
			player.FUEL -= 1
			score += 1
		elif int(player.FUEL) <= 10:
			player.FUEL -= 2
			score += 2
		elif int(player.FUEL) >= 1000:
			player.FUEL -= scoreCountdownRate
			score += scoreCountdownRate
		else:
			player.FUEL -= 10
			score += 10
		await get_tree().process_frame
		
func on_player_died():
	match gameMode:
		GameModes.ARCADE:
			if gameStateDisabled:
				background_music.pitch_scale = 1.03
				return
			lives -= 1
			gameStateDisabled = true
			$PlayerDeath.play()
			if lives > 0:
				await _display_info_duration("YOU DIED! RESETTING LEVEL...", 1.5)
				background_music.pitch_scale = 1.03
				game_started = false
				get_tree().reload_current_scene()
			else:
				if GameManager.level_data.high_score < score:
					await _display_info_duration("New High Score! " + str(score), 2.5)
					level_data.high_score = score
					save_data()
				else:
					await _display_info_duration("GAME OVER! BACK TO LEVEL 1 :) ", 1.5)
				time = 0.0
				reset()
				load_first_level()
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

func format_milliseconds(time_milliseconds: int) -> String:
	# Get minutes from milliseconds
	var minutes = time_milliseconds / (1000*60)
	var absoluteMinutes = floor(minutes);

	# Get remainder from minutes and convert to seconds
	var seconds = (time_milliseconds - (absoluteMinutes * 1000 * 60)) / 1000;
	var absoluteSeconds = floor(seconds);

	# Get remainder from minutes and and seconds
	var absoluteMilliseconds = (time_milliseconds - (absoluteSeconds * 1000) - (absoluteMinutes * 1000 * 60))

	return "%02d:%02d.%03d" % [absoluteMinutes, absoluteSeconds, absoluteMilliseconds]
