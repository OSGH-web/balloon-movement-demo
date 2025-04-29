extends TileMapLayer

func generate_border(width_in_tiles, height_in_tiles):
	for x in range(width_in_tiles):
		# Bottom border
		set_cell(Vector2i(x, height_in_tiles - 1), 0, Vector2i(7, 3), 0)
		# Top border
		set_cell(Vector2i(x, 0), 0, Vector2i(7, 3), 0)

	for y in range(1, height_in_tiles):
		# Left border
		set_cell(Vector2i(0, y), 0, Vector2i(7, 3), 0)
		# Right border
		set_cell(Vector2i(width_in_tiles - 1, y), 0, Vector2i(7, 3), 0)
