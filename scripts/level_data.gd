@tool
extends Resource
class_name LevelData

# Gets populated upon time trial level clear
@export var level_times = {}
# hard-coded developer best times for time trail levels. 
const dev_times = [9680, 9470, 4550, 5060, 23850, 19250, 600000, 17490, 19320, 600000, 600000, 600000, 600000, 600000, 600000]
@export var high_score = 0
@export var arcade_time = null
