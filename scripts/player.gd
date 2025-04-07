 # Player.gd (CharacterBody2D)
extends CharacterBody2D

@export var tilemaplayer: TileMapLayer
@export var FUEL = 2000
@export var play_background_music = false
@export var camera_scale: Vector2 = Vector2(1.0, 1.0)
@export var staticCam: bool = false
@onready var timer: Timer = $Timer
@onready var camera = $Camera

const GRAVITY = 120
const FRICTION = -3
const PLAYER_Y_FORCE = 300
const PLAYER_X_FORCE = 165
var readyForRestart: bool = false

signal player_died

func _on_player_died():
	readyForRestart = true

func _ready():
	add_to_group("player")
	_init_camera()
	$AudioStreamPlayer2D.playing = play_background_music
	player_died.connect(_on_player_died)
	var fuel_label = get_tree().get_first_node_in_group("fuel_label")
	if fuel_label:
		fuel_label.player = self

func add_fuel(amt):
	FUEL += amt
	$AudioStreamPlayer2D.pitch_scale = 1.03 # Changesmusic to normal if you ran out of fuel then got it back. 

func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
	if readyForRestart:
		if event.is_action_pressed("ui_a"):
			get_tree().reload_current_scene()
		if event.is_action_pressed("ui_q"):
			return_to_world_select()

func _on_timer_timeout():
	if int(FUEL) <= 0:
		emit_signal("player_died")
		
func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity_update = input_dir
	velocity_update.x *= PLAYER_X_FORCE * delta
	velocity_update.y *= PLAYER_Y_FORCE * delta

	if FUEL > 0:
		velocity -= velocity_update
		FUEL -= abs(velocity_update.x) + abs(velocity_update.y)
	elif readyForRestart == false and timer.is_stopped():
		$AudioStreamPlayer2D.pitch_scale = 0.7
		timer.start()
			
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif abs(velocity.x) < 0.001:
		velocity.x = 0
	else:
		# Makes you slow down when you land on the floor. Smaller than vel.x so slows you down. 
		velocity.x += FRICTION * delta * velocity.x

	move_and_slide()
	
	# This section nullifies unwanted velocity when flying into a wall/corner
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		# Normal is perpendicular to the you surface hit. 
		var normal: Vector2 = collision.get_normal()
		velocity = velocity.slide(normal)
		
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
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _init_camera():
	# by default, restrict the camera to the bounding box of the level
	var level_base: LevelBase = get_parent()
	var map_size_px = level_base.getMapSizePx()
	var map_width_px = map_size_px.x
	var map_height_px = map_size_px.y

	$Camera.limit_left = 0
	$Camera.limit_right = map_width_px
	$Camera.limit_top = 0;
	$Camera.limit_bottom = map_height_px

	# if the level is less wide than the screen, center the level horizontally in the camera's view
	var viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	if map_width_px < viewport_width:
		$Camera.limit_left = map_width_px / 2  - (viewport_width / 2)
		$Camera.limit_right = map_width_px / 2  + (viewport_width / 2)
		$Camera.drag_horizontal_enabled = false

	# if the level is shorter than the screen, center the level vertically in the camera's view
	var viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	if map_height_px < viewport_height:
		$Camera.limit_top = (map_height_px / 2) - (viewport_height / 2)
		$Camera.limit_bottom = (map_height_px / 2)  + (viewport_height / 2)
		$Camera.drag_vertical_enabled = false

	if staticCam:
		var level = get_parent() as Node2D
		camera.get_parent().remove_child(camera)
		call_deferred("add_camera_to_level", level, camera)
		camera.global_position = Vector2(map_width_px, map_height_px)

	camera.zoom = camera_scale

func add_camera_to_level(level: Node2D, cam: Camera2D):
	level.add_child(cam)
