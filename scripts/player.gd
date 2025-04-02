 # Player.gd (CharacterBody2D)
extends CharacterBody2D

@export var tilemaplayer: TileMapLayer

const GRAVITY = 120
const FRICTION = -3
const PLAYER_Y_FORCE = 300
const PLAYER_X_FORCE = 180

@export var FUEL = 2000;

func _ready():
	var level = get_parent() as Node2D
	var map_height_px = level.height_in_tiles * tilemaplayer.tile_size.y
	$Camera2D.limit_bottom = map_height_px

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity_update = input_dir
	velocity_update.x *= PLAYER_X_FORCE * delta
	velocity_update.y *= PLAYER_Y_FORCE * delta

	if FUEL > 0:
		velocity -= velocity_update
		FUEL -= abs(velocity_update.x) + abs(velocity_update.y)

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.x += FRICTION * delta * velocity.x

	move_and_slide()
	_update_animation(input_dir.normalized())

func _update_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		$AnimatedSprite2D.frame = 0
		return

	var x = dir.x
	var y = dir.y
	var is_diagonal = x != 0 and y != 0

	if is_diagonal:
		if x > 0:
			$AnimatedSprite2D.frame = 7 if y > 0 else 6  # down-right/up-right
		else:
			$AnimatedSprite2D.frame = 8 if y > 0 else 5  # down-left/up-left
	else:
		if x > 0:
			$AnimatedSprite2D.frame = 2  # right
		elif x < 0:
			$AnimatedSprite2D.frame = 4  # left
		elif y < 0:
			$AnimatedSprite2D.frame = 1  # up
		else:
			$AnimatedSprite2D.frame = 3  # down
