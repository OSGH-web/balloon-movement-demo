# LevelButton.gd
extends TextureButton
class_name LevelButton

@export var level_number: int = 1

@onready var label: Label = $Label

func _ready():
	if label:
		label.text = str(level_number)
