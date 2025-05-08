@tool
extends Resource
class_name LevelData

# Gets populated upon time trial level clear
@export var level_times = {}
# hard-coded developer best times for time trail levels. 
const dev_times: Array[int] = [9566, 9150, 4500, 5050, 21215, 16831, 14483, 14216, 15899, 10199, 28750, 11699, 4799, 16682, 31348]
const goal_times: Array[int] = [12000, 11500, 5750, 6300, 26500, 21000, 18000, 17777, 20000, 12750, 35000, 14500, 7500, 20000, 40000]
@export var high_score = 0
@export var arcade_time = null
