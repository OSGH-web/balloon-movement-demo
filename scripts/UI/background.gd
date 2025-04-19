@tool
extends TextureRect

# Colors
@export var light_color: Color = Color.WHITE:
	set(value):
		light_color = value
		_update_material()
@export var dark_color: Color = Color.BLACK:
	set(value):
		dark_color = value
		_update_material()
@export var invert_colors: bool = false:
	set(value):
		invert_colors = value
		_update_material()
# Scale parameters
@export var x_scale: float = 6.0:
	set(value):
		x_scale = value
		_update_material()
@export var y_scale: float = 4.0:
	set(value):
		y_scale = value
		_update_material()

func _ready():
	_update_material()

func _update_material():
	if invert_colors:
		material.set("shader_parameter/light_color", dark_color)
		material.set("shader_parameter/dark_color", light_color)
	else:
		material.set("shader_parameter/light_color", light_color)
		material.set("shader_parameter/dark_color", dark_color)
	
	material.set("shader_parameter/x_scale", x_scale)
	material.set("shader_parameter/y_scale", y_scale)
