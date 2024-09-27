#@tool

class_name AStarMap3D
extends Node3D

var map := AStar3D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not child_order_changed.is_connected(reload_map):
		child_order_changed.connect(reload_map)
		reload_map()


func reload_map() -> void:
	for node: Node in get_children():
		if node is not AStarNode3D:
			continue
		var n := node as AStarNode3D
		map.add_point(n.get_index(), n.position, n.weight)
		var new_connections: int = 0
		var point_ids: PackedInt64Array = map.get_point_ids()
		for i in range(map.get_point_count()):
			if new_connections >= n.max_new_connections:
				break
			var to: int = point_ids[i]
			if map.are_points_connected(n.get_index(), to):
				continue
			map.connect_points(n.get_index(), to)
			new_connections += 1
