extends Node2D

const SPEED = 40
var direction = 1
var turnAround = false
@onready var ray_r: RayCast2D = $RayCastRight
@onready var ray_dr: RayCast2D = $RayCastDownRight
@onready var ray_l: RayCast2D = $RayCastLeft
@onready var ray_dl: RayCast2D = $RayCastDownLeft


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $AnimatedSprite2D.frame in range(1,12):
		position.x += direction * SPEED * delta
		# Not checking every frame cause issues where the slime keeps going when they would have stopped. 
		if !turnAround:
			if ((direction == 1 and !ray_dr.is_colliding())
			or (direction == -1 and !ray_dl.is_colliding())
			or (direction == 1 and ray_r.is_colliding())
			or (direction == -1 and ray_l.is_colliding())):
				turnAround = true
				
	elif turnAround:
		direction = -direction
		$AnimatedSprite2D.flip_h = direction < 0
		turnAround = false
