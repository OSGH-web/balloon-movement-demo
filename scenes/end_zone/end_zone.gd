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
	if body.is_in_group("player"):
		return_to_world_select()

func return_to_world_select():
	get_tree().change_scene_to_file("res://scenes/level_select/level_select.tscn")

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
	color_rect.color = color
