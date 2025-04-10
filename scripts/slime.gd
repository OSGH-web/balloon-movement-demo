extends Node2D

const SPEED = 40

var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $AnimatedSprite2D.frame in range(1,12):
		position.x += direction * SPEED * delta
