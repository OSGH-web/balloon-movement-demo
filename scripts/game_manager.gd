# This GameManager is set to autoload in Project -> Project Settings -> Autoload
# This means that this scene will stay loaded through the entire game. 

extends Control
var curr_level = 0
var lives = 1
# TODO: Implement score feature and give extra lives for enough score.
var score = 0
var level_files = []
var levelComplete = false
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
	curr_level = 0
	background_music.pitch_scale = 1.03
	
func load_next_level():
	levelComplete = true
	if curr_level > 0:
		var player = get_player()
		# Prevents bug where level resets if enetering endzone when out of fuel. 
		endZoneTriggered = true
		# Freeze to prevent player death after endzone trigger
		player.set_physics_process(false)
		await get_tree().create_timer(2).timeout
		player.set_physics_process(true)
		endZoneTriggered = false
	var level_path = "res://levels/%s" % level_files[curr_level]
	curr_level += 1
	levelComplete = false
	get_tree().change_scene_to_file(level_path)
	
	
func _on_player_died():
	if endZoneTriggered:
		background_music.pitch_scale = 1.03
		return
	lives -= 1
	if lives > 0:
		%Player_Died.text = "YOU DIED! RESETTING LEVEL..."
		%Player_Died.visible = true
		await get_tree().create_timer(2).timeout
		background_music.pitch_scale = 1.03
		%Player_Died.visible = false
		get_tree().reload_current_scene()
	else:
		%Player_Died.text = "GAME OVER! BACK TO LEVEL 1 :) "
		%Player_Died.visible = true
		await get_tree().create_timer(2).timeout
		%Player_Died.visible = false
		reset()
		load_next_level()

func get_player(): 
	var level = get_tree().get_current_scene()
	return level.get_node("Player")
	

#func _process(delta: float):
	#if level_complete:
		#pass
