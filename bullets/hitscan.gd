class_name Hitscan 
extends Node3D


@export_flags_3d_physics var layer_mask: int = 0b0000_0000_0000_0000_0000_0000_0100_0101#69
@export_range(0.0, 1000.0, 0.1, "or_greater", "or_less") var max_range: float = 1000.0
@export_range(0.0, 1000.0, 0.1, "or_greater") var damage: float = 10.0
@export var player_damage_multiplier: Array[float] = [0.5, 1.0, 1.5, 2.0]
@export var damage_type: Status.DamageType = Status.DamageType.GENERIC
@export var explosion: PackedScene
@export_range(0.0, 100.0, 0.1, "or_greater") var knockback_force: float = 1.0
#@export var from_camera: bool = true
@export var piercer: bool = false
@export_range(0.0, 100.0, 0.1, "or_greater") var fade_speed: float = 50.0
@export_range(0.0, 5.0, 0.1, "or_greater") var linger: float = 0.0

# Defaults to some ridiculous coordinate b/c vector3 apparently isn't nullable
# (this could theoretically be solved by not declaring a type but that is a far
# worse sin in my eyes)
@export_storage var query_origin := Vector3(0.0, -1000.0, 0.0)
@export_storage var handled: bool = false
var exceptions: Array = []
@export_storage var invoker: Node3D
var linger_time: float = 0.0

@onready var mesh: Node3D = get_node_or_null("MeshInstance3D") as Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if query_origin.distance_squared_to(Vector3(0.0, -1000.0, 0.0)) <= Globals.C_EPSILON:
		query_origin = global_position
	if invoker:
		exceptions.append(invoker)
	#if from_camera:
		#camera = get_tree().root.find_child("Camera") as Camera3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not mesh:
		return
	if handled and linger_time >= linger:
		mesh.scale.z -= fade_speed * delta
		if mesh.scale.z < Globals.C_HITSCAN_MIN_LENGTH:
			queue_free()
	else:
		linger_time += delta


func _physics_process(_delta: float) -> void:
	if handled:
		if not mesh:
			queue_free()
		return

	handled = true
	var space = get_world_3d().direct_space_state
				#camera.global_position if from_camera
				#else global_position
		#)
	#print(query_origin)
	var query = PhysicsRayQueryParameters3D.create(
			query_origin,
			query_origin - (max_range * global_transform.basis.z),
			layer_mask
	)
	#print(exceptions)
	
	var new_excepts: Array = []
	for item in exceptions:
		if item != null:
			new_excepts.append(item)
	exceptions = new_excepts.duplicate()
	
	if not exceptions.is_empty():
		query.set_exclude(exceptions)

	var result: Dictionary = space.intersect_ray(query)

	if result:
		if mesh:
			mesh.global_position = result.position
			mesh.scale.z = result.position.distance_to(global_position)
			mesh.look_at(global_position)
		
		#if result.collider is RigidBody3D:
			#(result.collider as RigidBody3D).apply_impulse(global_basis.z, result.position)
		
		if result.collider.has_method("apply_knockback"):
			result.collider.apply_knockback(knockback_force * (
					result.collider.global_position - global_position
			).normalized())
		
		if result.collider.has_node("Status"):
			var status: Status = result.collider.find_child("Status")
			if (
					result.collider is EnemyBase
					and invoker != null
					and invoker != result.collider
			):
				result.collider.detect_target(invoker, EnemyBase.DetectionType.RETALIATION)
			
			damage -= status.damage(damage * (
					player_damage_multiplier[Globals.s_difficulty]
					if status is PlayerStatus
					else 1.0
			))
			exceptions.append(result.collider)
			if damage > 0 and piercer:
				handled = false
		
		elif result.collider is LodgedNail:
			result.collider.supercharged = true
			result.collider.primed = true
			exceptions.append(result.collider)
			handled = false
		
		var exp: Node3D = explosion.instantiate()
		get_tree().current_scene.add_child(exp)
		exp.global_position = result.position
		if exp.find_child("Area3D") is AreaDamage:
			exp.find_child("Area3D").invoker = invoker
		
	elif mesh: # if the bullet didn't hit anything
		mesh.global_position = global_position - max_range * global_transform.basis.z
		mesh.scale.z = max_range - 1
		mesh.look_at(global_position)
