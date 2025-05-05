@tool
extends Resource
class_name LevelData

# Gets populated upon time trial level clear
@export var level_times = {}
# hard-coded developer best times for time trail levels. 
const dev_times = ["00:09:68", "00:09:46", "00:04:65", "00:05:13", "00:25:71", "10:00:00", "10:00:00", "10:00:00", "10:00:00", "10:00:00", "10:00:00", "10:00:00", "10:00:00", "10:00:00", "10:00:00"]
@export var high_score = 0
@export var arcade_time = null
