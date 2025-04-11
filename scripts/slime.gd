extends Node2D

enum Dir { LEFT = -1, RIGHT = 1 }

const SPEED = 40
var direction = Dir.RIGHT
var turnAround = false
@onready var ray_r: RayCast2D = $RayCastRight
@onready var ray_dr: RayCast2D = $RayCastDownRight
@onready var ray_l: RayCast2D = $RayCastLeft
@onready var ray_dl: RayCast2D = $RayCastDownLeft
@export var flip_h = false

func _ready():
	# Allows for changing direction upon level start
	if flip_h:
		$AnimatedSprite2D.flip_h = true
		direction = Dir.LEFT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $AnimatedSprite2D.frame in range(Dir.RIGHT,12):
		position.x += direction * SPEED * delta
		# Not checking every frame cause issues where the slime keeps going when they would have stopped. 
		if !turnAround:
			if ((direction == Dir.RIGHT and !ray_dr.is_colliding())
			or (direction == Dir.LEFT and !ray_dl.is_colliding())
			or (direction == Dir.RIGHT and ray_r.is_colliding())
			or (direction == Dir.LEFT and ray_l.is_colliding())):
				turnAround = true
	elif turnAround:
		direction = -direction
		$AnimatedSprite2D.flip_h = direction == Dir.LEFT
		turnAround = false

