extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $AnimatedSprite2D.frame in range(1,12):
		position.x +=1
