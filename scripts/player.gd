 # Player.gd (CharacterBody2D)
extends CharacterBody2D

@export var FUEL = 2000
@export var camera_scale: Vector2 = Vector2(1.0, 1.0)
@export var staticCam: bool = false
@onready var timer: Timer = $Timer
@onready var camera = $Camera

@onready var ray_dl: RayCast2D = %RayCastDownRight
@onready var ray_dr: RayCast2D = %RayCastDownLeft

# physics are designed for an 8px x 8px tileset -- 8px == 1m
const BASE_TILE_SIZE_PX = 8
@export var tile_size_px = 24
@export var physics_scale_factor = tile_size_px / BASE_TILE_SIZE_PX

# All forces are in units of Tiles per Second squared
# friction is a ratio and doesn't need to be scaled
const FRICTION = -3

var gravity = 120 * physics_scale_factor
var player_y_force = 300 * physics_scale_factor
var player_x_force = 165 * physics_scale_factor
var velocity_cutoff = 0.001 * physics_scale_factor

# Tilemap data
const ICE_SOURCE_ID := 5
const ICE_ATLAS_COORDS := [Vector2i(0, 0), Vector2i(1, 0)]

signal player_died

var airbrake_pressed = false

func _ready():
	add_to_group("player")
	camera.zoom = camera_scale
	player_died.connect(GameManager.on_player_died)

func add_fuel(amt):
	FUEL += amt
	GameManager.background_music.pitch_scale = 1.03 # Changes music to normal if you ran out of fuel then got it back. 

func _on_timer_timeout():
	if int(FUEL) <= 0:
		emit_signal("player_died")

func _get_friction():
	var tilemap: TileMapLayer = $"../Terrain"

	for ray in [ray_dl, ray_dr]:
		if ray.is_colliding():
			var foot_position = ray.get_collision_point()
			var tile_pos = tilemap.local_to_map(foot_position)
			var source_id = tilemap.get_cell_source_id(tile_pos)
			var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)

			# Check if tile is NOT ice
			if not (source_id == ICE_SOURCE_ID && atlas_coords in ICE_ATLAS_COORDS):
				return FRICTION

	return 0.0;


func _input(event):
	if event.is_action_pressed("ui_a"):
		airbrake_pressed = true
	if event.is_action_released("ui_a"):
		airbrake_pressed = false


func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity_update = input_dir
	velocity_update.x *= player_x_force * delta
	velocity_update.y *= player_y_force * delta

	if FUEL > 0:
		velocity -= velocity_update
		# fuel is independent of scale
		FUEL -= velocity_update.length() / physics_scale_factor
	elif timer.is_stopped():
		GameManager.background_music.pitch_scale = 0.7
		timer.start()

	if not is_on_floor():
		velocity.y += gravity * delta
		# only airbrake if the player is not otherwise moving
		if airbrake_pressed && velocity_update == Vector2.ZERO:
			velocity.x += FRICTION * delta * velocity.x
	elif abs(velocity.x) < velocity_cutoff:
		velocity.x = 0
	else:
		velocity.x += _get_friction() * delta * velocity.x

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
		if airbrake_pressed:
			$AnimatedSprite2D.frame = 9
			return
		else:
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


func _setup_camera_limits(map_width_px, map_height_px):
	# by default, restrict the camera to the bounding box of the level
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
		
func add_camera_to_level(level: Node2D, cam: Camera2D):
	level.add_child(cam)
	
