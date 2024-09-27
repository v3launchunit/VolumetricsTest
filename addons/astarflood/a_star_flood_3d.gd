@tool

class_name AStarFlood3D
extends Marker3D

@export var bake: bool = false:
	set(to):
		a_star.clear()
		is_baking = true
@export var is_baking: bool = false
@export_range(1.0, 32.0, 0.1, "or_greater", "suffix:m") var node_distance: float = 8.0
@export_flags_3d_physics var collision_mask: int = \
		0b0000_0000_0000_0000_0000_0000_1000_0001
@export_range(1, 32, 1, "or_greater") var max_new_connections: int = 8
@export var region := AABB(Vector3(-32.0, -32.0, -32.0), Vector3(64.0, 64.0, 64.0)):
	set(to):
		region = to

var a_star := AStar3D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_baking and Engine.is_editor_hint():
		pass
