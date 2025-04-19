extends TileMapLayer

func generate_border(width_in_tiles, height_in_tiles):
	for x in range(width_in_tiles):
		# Bottom border
		set_cell(Vector2i(x, height_in_tiles - 1), 1, Vector2i(1, 2), 0)
		# Top border
		set_cell(Vector2i(x, 0), 1, Vector2i(1, 2), 0)

	for y in range(1, height_in_tiles):
		# Left border
		set_cell(Vector2i(0, y), 1, Vector2i(1, 2), 0)
		# Right border
		set_cell(Vector2i(width_in_tiles - 1, y), 1, Vector2i(1, 2), 0)
