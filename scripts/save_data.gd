class_name SaveData
extends Node


@export_storage var data : Dictionary[NodePath, Dictionary] = {}


func save_node(node: Node) -> void:
	data[node.get_path()] = {}
	for p in node.get_property_list():
		data[node.get_path()][p["name"]] = node.get(p["name"])


func load_all() -> void:
	for path in data:
		load_node(path)


func load_node(path: NodePath) -> void:
	var n : Node = get_node(path)
	for p in data[path]:
		n.set(p, data[path][p])
