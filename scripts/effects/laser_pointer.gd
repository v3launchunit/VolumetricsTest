extends Node3D


@onready var mesh := get_node("MeshInstance3D") as Node3D
@onready var raycast := get_node("RayCast3D") as RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if raycast.is_colliding():
		mesh.global_position = raycast.get_collision_point()
		mesh.scale.z = raycast.get_collision_point().distance_to(global_position)
		mesh.look_at(global_position)
	else:
		mesh.position = raycast.target_position
		mesh.scale.z = raycast.target_position.length()
		mesh.look_at(global_position)
