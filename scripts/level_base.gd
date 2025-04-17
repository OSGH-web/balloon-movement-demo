@tool
extends Node2D

@export var level_name := ""

@export var width_in_tiles := 32:
	set(value):
		width_in_tiles = value
		_update_level_bounds()  # Refresh when changed

@export var height_in_tiles := 64:
	set(value):
		height_in_tiles = value
		_update_level_bounds()  # Refresh when changed

func _ready():
	_update_level_bounds()
	_update_player_camera()
	_update_background_color()


func _update_background_color():
	var hue = (float(GameManager.curr_level)/float(len(GameManager.level_files)))
	var bg_color = Color.from_hsv(hue, 0.5, 0.35 + (.35 * ((GameManager.curr_level + 1) % 2)), 1)
	bg_color = getClosestEDG32Color(bg_color)

	print("setting background to: " + str(bg_color))
	RenderingServer.set_default_clear_color(bg_color)

# Define the EDG32 palette (32 colors)
var EDG32_PALETTE = [
	Color8(0, 0, 0), Color8(34, 32, 52), Color8(69, 40, 60), Color8(102, 57, 49),
	Color8(143, 86, 59), Color8(223, 113, 38), Color8(217, 160, 102), Color8(238, 195, 154),
	Color8(251, 242, 54), Color8(153, 229, 80), Color8(106, 190, 48), Color8(55, 148, 110),
	Color8(75, 105, 47), Color8(82, 75, 36), Color8(50, 60, 57), Color8(63, 63, 116),
	Color8(48, 96, 130), Color8(91, 110, 225), Color8(99, 155, 255), Color8(95, 205, 228),
	Color8(203, 219, 252), Color8(255, 255, 255), Color8(155, 173, 183), Color8(132, 126, 135),
	Color8(105, 106, 106), Color8(89, 86, 82), Color8(118, 66, 138), Color8(172, 50, 50),
	Color8(217, 87, 99), Color8(215, 123, 186), Color8(143, 151, 74), Color8(138, 111, 48)
]

# Function to get closest EDG32 palette color
func getClosestEDG32Color(color: Color) -> Color:
	var closest_color = EDG32_PALETTE[0]
	var min_distance = INF
	for palette_color in EDG32_PALETTE:
		var distance = color_distance(color, palette_color)
		if distance < min_distance:
			min_distance = distance
			closest_color = palette_color
	return closest_color

# Euclidean distance in RGB space
func color_distance(c1: Color, c2: Color) -> float:
	var dr = c1.r - c2.r
	var dg = c1.g - c2.g
	var db = c1.b - c2.b
	return dr * dr + dg * dg + db * db  # No need to sqrt for comparison



func _update_player_camera():
	if Engine.is_editor_hint():
		return; # only run in the game
	if $Player:
		$Player._setup_camera_limits(width_in_tiles * 8 * $Player.physics_scale_factor, height_in_tiles * 8 * $Player.physics_scale_factor)

func _update_level_bounds():
	if !Engine.is_editor_hint():
		return  # Only run in the editor

	# Clear existing ColorRect (if any)
	for child in get_children():
		if child is ColorRect:
			child.queue_free()

	# Create new bounds overlay
	var tilemap = get_node_or_null("Terrain")
	if !tilemap:
		return

	var rect = ColorRect.new()
	rect.color = Color(1, 0, 0, 0.1)
	rect.size = Vector2(
		width_in_tiles * tilemap.tile_set.tile_size.x,
		height_in_tiles * tilemap.tile_set.tile_size.y
	)
	add_child(rect)
	rect.z_index = 1  # Render behind tiles
