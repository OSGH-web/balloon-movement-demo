@tool
extends EditorScript
# Prints a given scene's node structure in human-readable format
# Execute with Shift + Ctrl + X

@export var scene_path := "res://scenes/level_select.tscn"

func _run():
	var packed_scene := load(scene_path)
	var scene_instance = packed_scene.instantiate()
	print("Node tree for: " + scene_path)
	print_node_tree(scene_instance)

func print_node_tree(node: Node, indent: int = 0):
	var out = ""
	for _i in range(indent):
		out += "    "
	out += "- " + node.name + " (" + node.get_class() + ")"
	print(out)
	for child in node.get_children():
		print_node_tree(child, indent + 1)
