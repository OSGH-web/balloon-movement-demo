@tool
extends Area2D

@export var size: Vector2 = Vector2(48, 16) :
	set = set_size  # Calls `set_size` when changed in the Inspector
@export var color: Color = Color(1, 0, 0, 0.5) :
	set = set_color  # Calls `set_color` when changed in the Inspector
@onready var collision_shape = $CollisionShape2D
@onready var color_rect = $ColorRect
func _ready():
	body_entered.connect(_on_body_entered)
	update_shape()

func _on_body_entered(body):
	if body.is_in_group("player") and not GameManager.gameStateDisabled:
		if GameManager.gameMode == GameManager.GameModes.ARCADE:
			GameManager.load_next_level()
		elif GameManager.gameMode == GameManager.GameModes.TIME_TRIAL:
			GameManager.save_time_and_return()

func _process(_delta):
	if Engine.is_editor_hint():  # Only update in the editor
		update_shape()

func update_shape():
	if not is_inside_tree():  # Prevent errors before node is fully initialized
		return
	# Update CollisionShape2D (assuming a RectangleShape2D)
	if collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = size

	# Update ColorRect
	color_rect.size = size
	color_rect.position = -size / 2  # Center it on Area2D
	color_rect.color = color  # Set the color

func set_size(new_size: Vector2):
	size = new_size
	update_shape()

func set_color(new_color: Color):
	color = new_color
	if color_rect:
		color_rect.color = color
