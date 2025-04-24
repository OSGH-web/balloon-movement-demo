extends CanvasLayer

@export var player: CharacterBody2D

func _ready():
	if GameManager.gameMode == GameManager.GameModes.TIME_TRIAL:
		%Lives.visible = false
		%Score.visible = false
			

func _process(delta: float) -> void:
	if not player:
		return

	var fuel_amount = max(0, int(player.FUEL))
	%Fuel.text = "Fuel: %d" % fuel_amount
	if GameManager.gameMode == GameManager.GameModes.ARCADE:
		%Lives.text = "Lives: %d" % GameManager.lives
		%Score.text = "Score: %d" % GameManager.score
	%Timer.text = _format_seconds(GameManager.time)

func _format_seconds(time : float) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	var milliseconds := fmod(time, 1) * 100

	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
