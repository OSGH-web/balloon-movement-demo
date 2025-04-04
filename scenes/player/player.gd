 # Player.gd (CharacterBody2D)
extends CharacterBody2D

@export var tilemaplayer: TileMapLayer
@export var FUEL = 2000
@export var play_background_music = false
@export var camera_scale: Vector2 = Vector2(1.0, 1.0)
@export var staticCam: bool = false
@onready var timer: Timer = $Timer

const GRAVITY = 120
const FRICTION = -3
const PLAYER_Y_FORCE = 300
const PLAYER_X_FORCE = 165
var readyForRestart: bool = false

func _ready():
	var camera = $Camera
	camera.zoom = camera_scale
	$AudioStreamPlayer2D.playing = play_background_music
	add_to_group("player")
	var level = get_parent() as Node2D
	var map_height_px = level.height_in_tiles * tilemaplayer.tile_size.y
	var map_width_px = level.width_in_tiles * tilemaplayer.tile_size.x

	var fuel_label = get_tree().get_first_node_in_group("fuel_label")
	if fuel_label:
		fuel_label.player = self
	if staticCam:
		# Remove the player and reparent to level.
		camera.get_parent().remove_child(camera)
		call_deferred("add_camera_to_level", level, camera)
		# Set position in the center of the level.
		camera.global_position = Vector2(map_width_px, map_height_px) / 2
		camera.enabled = true
		camera.make_current()
		
# Seperate function bc if we don't wait a frame the call will fail. 
func add_camera_to_level(level: Node2D, camera: Camera2D):
	level.add_child(camera)
	
	
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

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity_update = input_dir
	velocity_update.x *= PLAYER_X_FORCE * delta
	velocity_update.y *= PLAYER_Y_FORCE * delta

	if FUEL > 0:
		velocity -= velocity_update
		FUEL -= abs(velocity_update.x) + abs(velocity_update.y)
		if $AudioStreamPlayer2D.pitch_scale == 0.7:
			$AudioStreamPlayer2D.pitch_scale = 1
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
	
# Revisit this if we need to set camera limits. Causes more problems than it's worth at the moment. 
#func _setup_camera_limits():
	#var level = get_parent() as Node2D
	#var tilemap = level.get_node("Terrain")
	#var tile_size = tilemap.tile_set.tile_size
#
	#var map_width_px = level.width_in_tiles * tile_size.x
	#var map_height_px = level.height_in_tiles * tile_size.y
	#var level_offset = level.global_position
#
	#$Camera2D.limit_left = int(level_offset.x)
	#$Camera2D.limit_top = int(level_offset.y)
	#$Camera2D.limit_right = int(level_offset.x + map_width_px)
	#$Camera2D.limit_bottom = int(level_offset.y + map_height_px)
