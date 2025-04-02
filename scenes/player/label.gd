extends Label

var cl: CanvasLayer
var player: CharacterBody2D

func _ready() -> void:
	cl = get_parent() as CanvasLayer
	player = cl.get_parent() as CharacterBody2D

func _process(_delta: float) -> void:
	if int(player.FUEL) <= 0:
		text = "Press A to retry level" + "\n" + "Press Q to return to level select"
	else:
		text = "Fuel: " + str(int(player.FUEL))
