@tool
extends TextureRect

# Colors
@export var light_color: Color = Color.WHITE:
	set(value):
		light_color = value
		material.set("shader_parameter/light_color", light_color)
@export var dark_color: Color = Color.BLACK:
	set(value):
		dark_color = value
		material.set("shader_parameter/dark_color", dark_color)

# Scale parameters
@export var x_scale: float = 6.0:
	set(value):
		x_scale = value
		material.set("shader_parameter/x_scale", x_scale)
@export var y_scale: float = 4.0:
	set(value):
		y_scale = value
		material.set("shader_parameter/y_scale", y_scale)
