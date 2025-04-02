 # Player.gd (CharacterBody2D)
extends CharacterBody2D

@export var tilemaplayer: TileMapLayer

const GRAVITY = 120
const FRICTION = -3
const PLAYER_Y_FORCE = 300
const PLAYER_X_FORCE = 180

@export var FUEL = 2000;

@export var play_background_music = false;

@onready var timer: Timer = $Timer

var readyForRestart: bool = false

func _ready():
	add_to_group("player")
	var level = get_parent() as Node2D
	var map_height_px = level.height_in_tiles * tilemaplayer.tile_size.y
	$Camera2D.limit_bottom = map_height_px
	$AudioStreamPlayer2D.playing = play_background_music
	var fuel_label = get_tree().get_first_node_in_group("fuel_label")
	if fuel_label:
		fuel_label.player = self

func add_fuel(amt):
	FUEL += amt
	if FUEL > 0:
		$Timer.stop()
		$AudioStreamPlayer2D.pitch_scale = 1.03
	if readyForRestart:
		readyForRestart = false

func _input(event):
	if int(FUEL) <= 0:
		if timer.is_stopped() and readyForRestart == false:
			timer.start()
	if readyForRestart:
		if event.is_action_pressed("ui_a"):
			get_tree().reload_current_scene()
		if event.is_action_pressed("ui_q"):
			return_to_world_select()


func _on_timer_timeout():
	readyForRestart = true
	print("HERE")

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity_update = input_dir
	velocity_update.x *= PLAYER_X_FORCE * delta
	velocity_update.y *= PLAYER_Y_FORCE * delta

	if FUEL > 0:
		velocity -= velocity_update
		FUEL -= abs(velocity_update.x) + abs(velocity_update.y)
	else:
		$AudioStreamPlayer2D.pitch_scale = 0.7

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif abs(velocity.x) < 0.001:
		velocity.x = 0
	else:
		# Makes you slow down when you land on the floor. Smaller than vel.x so slows you down. 
		velocity.x += FRICTION * delta * velocity.x

	move_and_slide()
	_update_animation(input_dir.normalized())

func _update_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		$AnimatedSprite2D.frame = 0
		return

	if int(FUEL) <= 0:
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
func return_to_world_select():
	get_tree().change_scene_to_file("res://scenes/level_select/level_select.tscn")
