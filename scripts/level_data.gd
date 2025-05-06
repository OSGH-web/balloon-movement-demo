@tool
extends Resource
class_name LevelData

# Gets populated upon time trial level clear
@export var level_times = {}
# hard-coded developer best times for time trail levels. 
const dev_times: Array[int] = [9680, 9470, 4550, 5058, 23850, 19250, 15220, 17490, 19320, 11160, 28850, 12800, 5050, 17920, 38380]
@export var high_score = 0
@export var arcade_time = null
