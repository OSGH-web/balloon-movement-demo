extends CanvasLayer

@export var player: CharacterBody2D

func _ready():
	add_to_group("fuel_label")

func _process(_delta: float) -> void:
	if player:
		if int(player.FUEL) <= 0:
			$Label.text = "Press A to retry level\nPress Q to return to level select"
		else:
			$Label.text = "Fuel: " + str(int(player.FUEL))
