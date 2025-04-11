extends Node

const SAVE_PATH := "user://level_data.tres"
static var level_data: LevelData = LevelData.new()

func _ready() -> void:
	load_data()

static func save_data() -> void:
	ResourceSaver.save(level_data, SAVE_PATH)

static func load_data() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		level_data = load(SAVE_PATH)
	else:
		level_data = LevelData.new()
		save_data()

static func mark_level_completed(level_path: String) -> void:
	level_data.completed_levels[level_path] = true
	save_data()

static func is_level_completed(level_path: String) -> bool:
	return level_data.completed_levels.get(level_path, false)
