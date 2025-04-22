extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	if not GameManager.gameStateDisabled:
		_body.die()
