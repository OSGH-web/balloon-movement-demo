# Empty main scene for flexibility later on. If we want an intro cutscene/main menu for example.
extends Node

func _ready():
	GameManager.load_next_level()
