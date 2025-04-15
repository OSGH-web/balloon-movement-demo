extends CanvasLayer

@export var player: CharacterBody2D

func _process(_delta: float) -> void:
	if not player:
		return
	
	var fuel_amount = max(0, int(player.FUEL))
	%Fuel.text = "Fuel: %d" % fuel_amount
	%Lives.text = "Lives: %d" % GameManager.lives	
	if GameManager.levelComplete:
		%Level_Complete.visible = true
	else:
		%Level_Complete.visible = false
