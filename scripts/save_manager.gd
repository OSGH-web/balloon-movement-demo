extends Node

const SAVE_PATH := "user://level_data.tres"
var level_data: LevelData

func _ready() -> void:
	load_data()

func save_data() -> void:
	ResourceSaver.save(level_data, SAVE_PATH)

func load_data() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		level_data = load(SAVE_PATH)
	else:
		level_data = LevelData.new()
		save_data()

func mark_level_completed(level_path: String) -> void:
	level_data.completed_levels[level_path] = true
	save_data()

func is_level_completed(level_path: String) -> bool:
	return level_data.completed_levels.get(level_path, false)
