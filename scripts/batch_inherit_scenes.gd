@tool
extends EditorScript

func _run():
	var base_scene_path = "res://scenes/level_base.tscn"
	var levels_dir = "res://levels"  # <- Change this to your levels folder

	var base_scene = load(base_scene_path)
	if base_scene == null:
		push_error("Could not load base scene.")
		return

	var dir = DirAccess.open(levels_dir)
	if dir == null:
		push_error("Could not open levels directory.")
		return

	for file_name in dir.get_files():
		if not file_name.ends_with(".tscn"):
			continue

		var level_scene_path = levels_dir + "/" + file_name
		var level_scene = load(level_scene_path)
		if level_scene == null:
			push_error("Could not load scene: " + level_scene_path)
			continue

		var old_root = level_scene.instantiate()
		var inherited_scene = PackedScene.new()
		
		var new_root = load(base_scene_path).instantiate()

		# Copy children from old root to new inherited root
		for child in old_root.get_children():
			old_root.remove_child(child)
			new_root.add_child(child)
			child.owner = new_root

		inherited_scene.pack(new_root)
		ResourceSaver.save(level_scene_path, inherited_scene)
		print("Converted to inherited scene:", level_scene_path)
		return
