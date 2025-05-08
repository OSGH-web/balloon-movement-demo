@tool
extends Resource
class_name LevelData

# Gets populated upon time trial level clear
@export var level_times = {}
# hard-coded developer best times for time trail levels. 
const dev_times: Array[int] = [9566, 9150, 4500, 5050, 21215, 16831, 14483, 14216, 15899, 10199, 28750, 11699, 4799, 16682, 31348]
@export var high_score = 0
@export var arcade_time = null
