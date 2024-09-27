extends Bullet

@onready var camera: Camera3D = get_tree().get_first_node_in_group("player_cam")
@onready var sightline: RayCast3D = camera.get_node("Sightline") as RayCast3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if sightline.is_colliding():
		look_at(sightline.get_collision_point())


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if sightline.is_colliding():
		look_at(sightline.get_collision_point())
		state.linear_velocity = -speed * global_transform.basis.z.normalized()
