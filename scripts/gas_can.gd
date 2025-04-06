class_name GasCan
extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_fuel(1000)
		# Collision, sound, and queue_free() are all handled here. 
		animation_player.play("pickup")
