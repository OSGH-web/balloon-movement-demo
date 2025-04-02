extends Area2D

@export var collect_sound: AudioStream
@onready var audio_player = $AudioStreamPlayer
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	body_entered.connect(_on_body_entered)
	if collect_sound:
		audio_player.stream = collect_sound

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_fuel(1000)
		# Disable collision and hide sprite immediately
		collision.set_deferred("disabled", true)
		sprite.visible = false
		# Play sound
		audio_player.play()
		# Delete after sound finishes
		await audio_player.finished
		queue_free()
