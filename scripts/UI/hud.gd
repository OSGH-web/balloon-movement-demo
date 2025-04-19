extends CanvasLayer

@export var player: CharacterBody2D

var time: float = 0.0;

func _process(delta: float) -> void:
	if not GameManager.endZoneTriggered:
		time += delta;

	if not player:
		return

	var fuel_amount = max(0, int(player.FUEL))
	%Fuel.text = "Fuel: %d" % fuel_amount
	%Lives.text = "Lives: %d" % GameManager.lives
	%Score.text = "Score: %d" % GameManager.score
	%Timer.text = _format_seconds(time)

func _format_seconds(time : float) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)

	#return "%02d:%02d" % [minutes, seconds]
	var milliseconds := fmod(time, 1) * 100

	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
