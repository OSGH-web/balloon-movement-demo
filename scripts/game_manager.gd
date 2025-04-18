# This GameManager is set to autoload in Project -> Project Settings -> Autoload
# This means that this scene will stay loaded through the entire game. 

extends Control
var curr_level = 0
var lives = 1
# 10k score gives an extra life. You automatically get 1k per level, plus however much fuel you have left over. 
var score = 0
var extraLivesDivisor = 1
var extraLifeFrameDelay = .5 # value in seconds. time between life increases when receiving multiple lives
var level_files = []
var endZoneTriggered = false
# Show a message upon levelCompletion
@onready var background_music = $Background_Music
func _ready():
	load_levels()

func load_levels():
	var dir = DirAccess.open("res://levels/")
	if dir:
		level_files.clear()
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				level_files.append(file_name)
			file_name = dir.get_next()
		level_files.sort()
		dir.list_dir_end()
		
func reset():
	lives = 3
	score = 0
	extraLivesDivisor = 1
	curr_level = 0
	background_music.pitch_scale = 1.03
	
func load_next_level():
	if curr_level > 0:
		background_music.pitch_scale = 1.03
		# Prevents bug where level resets if entering endzone when out of fuel. 
		endZoneTriggered = true
		# Freeze to prevent player death after endzone trigger
		await calculateScore() 
		await get_tree().create_timer(1).timeout
	var level_path = "res://levels/%s" % level_files[curr_level]
	curr_level += 1
	get_tree().change_scene_to_file(level_path)
	# Must go after changing scene to avoid issues.
	endZoneTriggered = false
	
func _input(event):
	 # Go to next level
	if event.is_action_pressed("ui_n"):
		var level_path = "res://levels/%s" % level_files[curr_level]
		curr_level += 1
		if curr_level == len(level_files):
			curr_level = 0
		get_tree().change_scene_to_file(level_path)

	# Go to previous level
	if event.is_action_pressed("ui_p"):
		curr_level -= 1
		var level_path
		if curr_level >= 1:
			level_path = "res://levels/%s" % level_files[curr_level - 1]
		else:
			curr_level = len(level_files) - 1
			level_path = "res://levels/%s" % level_files[len(level_files) - 1]

		get_tree().change_scene_to_file(level_path)

func calculateScore():
	%GameInfo.text = "Level Complete! +1000 Score!"
	%GameInfo.visible = true
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
	if endZoneTriggered:
		background_music.pitch_scale = 1.03
		return
	lives -= 1
	if lives > 0:
		%GameInfo.text = "YOU DIED! RESETTING LEVEL..."
		%GameInfo.visible = true
		await get_tree().create_timer(2).timeout
		background_music.pitch_scale = 1.03
		%GameInfo.visible = false
		get_tree().reload_current_scene()
	else:
		%GameInfo.text = "GAME OVER! BACK TO LEVEL 1 :) "
		%GameInfo.visible = true
		await get_tree().create_timer(2).timeout
		%GameInfo.visible = false
		reset()
		load_next_level()

func get_player(): 
	var level = get_tree().get_current_scene()
	return level.get_node("Player")
