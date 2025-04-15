# This GameManager is set to autoload in Project -> Project Settings -> Autoload
# This means that this scene will stay loaded through the entire game. 

extends Control

var curr_level = 0
var lives = 3
var score = 0
var score_for_extra_life = 2000
var level_files = []

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
		
func load_next_level():
	var level_path = "res://levels/%s" % level_files[curr_level]
	curr_level += 1
	get_tree().change_scene_to_file(level_path)
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float):
	#pass
