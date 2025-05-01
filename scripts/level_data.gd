@tool
extends Resource
class_name LevelData

# Gets populated upon time trial level clear
@export var level_times = {}

@export var high_score = 0

# Null until best time is set
@export var arcade_time = null
