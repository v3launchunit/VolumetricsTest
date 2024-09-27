class_name HomingRocket
extends Bullet

## The layer(s) that the rocket will scan while looking for targets.
@export_flags_3d_physics var target_layers: int = 4
@export_range(0.1, 35, 0.1, "or_greater") var turning_speed: float = 2.5

@export var target: Node3D

var target_scan_attempts = 0

@onready var scan_area: Area3D = $Area3D
@onready var scan_shape: SphereShape3D = $Area3D/CollisionShape3D.shape


func _ready():
	super()
	scan_area.collision_mask = target_layers
	scan_area.body_entered.connect(_on_area_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if target == null:
		scan_shape.radius = target_scan_attempts + 1
		target_scan_attempts += 1
	else:
		scan_area.look_at(target.global_position)
		var a = Quaternion(global_basis)
		var b = Quaternion(scan_area.global_basis)
		a = a.slerp(b, min(delta * turning_speed, 1.0))
		global_basis = Basis(a)
		scan_area.look_at(target.global_position)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = -speed * transform.basis.z.normalized()
#	if target == null:
#		state.integrate_forces()
#	else:


func _on_area_body_entered(body: Node3D) -> void:
	if body is EnemyBase and target == null:
		target = body
		#print("target found: %s" % target)
