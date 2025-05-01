extends CanvasLayer

@export var player: CharacterBody2D

func _ready():
	if GameManager.gameMode == GameManager.GameModes.TIME_TRIAL:
		%Lives.visible = false
		%Score.visible = false
		%Fuel.position.y = 25
		%Timer.position.y = 25
			

func _process(delta: float) -> void:
	if not player:
		return

	var fuel_amount = max(0, int(player.FUEL))
	%Fuel.text = "Fuel: %d" % fuel_amount
	if GameManager.gameMode == GameManager.GameModes.ARCADE:
		%Lives.text = "Lives: %d" % GameManager.lives
		%Score.text = "Score: %d" % GameManager.score
	%Timer.text = GameManager.format_seconds(GameManager.time)
