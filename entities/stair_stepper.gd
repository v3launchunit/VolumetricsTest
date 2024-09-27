extends Node3D

@onready var low_cast := $LowCast as ShapeCast3D
@onready var high_cast := $HighCast as ShapeCast3D
@onready var snap_cast := $SnapCast as ShapeCast3D
@onready var body := get_parent_node_3d() as CharacterBody3D
#@onready var step_cast: ShapeCast3D = $StepCast as ShapeCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	low_cast.target_position = (
			body.velocity.normalized()
			* body.transform.basis
	) * Vector3(1.0, 0.0, 1.0)
	high_cast.target_position = (
			body.velocity.normalized()
			* body.transform.basis
	) * Vector3(1.0, 0.0, 1.0)
	if (
			body.is_on_floor()
			and body.velocity.distance_squared_to(Vector3.ZERO) >= Globals.C_EPSILON
			and low_cast.is_colliding()
			and not high_cast.is_colliding()
			#and low_cast.get_collision_normal(0).angle_to(Vector3.UP) >= body.floor_max_angle
	):
		body.translate(Vector3(0.0, 0.55, 0.0))
		if body is Player:
			body.cam_y_offset -= 0.55
		await get_tree().process_frame
		#body.apply_floor_snap()
		#body.translate(
				#(snap_cast.global_position - snap_cast.get_collision_point(0))
				#* Vector3.UP
		#)
