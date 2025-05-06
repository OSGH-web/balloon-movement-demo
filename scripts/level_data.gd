@tool
extends Resource
class_name LevelData

# Gets populated upon time trial level clear
@export var level_times = {}
# hard-coded developer best times for time trail levels. 
const dev_times = [9.68, 9.47, 4.55, 5.06, 23.85, 19.25, 15.22, 17.49, 19.32, 11.16, 28.85, 12.80, 5.05, 17.92, 38.38]
@export var high_score = 0
@export var arcade_time = null
