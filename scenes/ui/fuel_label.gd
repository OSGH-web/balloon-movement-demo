extends CanvasLayer

@export var player: CharacterBody2D

func _ready():
	add_to_group("fuel_label")

func _process(_delta: float) -> void:
	if not player:
		return

	var fuel_amount = max(0, int(player.FUEL))

	if player.readyForRestart:
		$Label.text = "Press A to retry level\nPress Q to return to level select"
	else:
		$Label.text = "Fuel: %d" % fuel_amount
