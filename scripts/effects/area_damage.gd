class_name AreaDamage
extends Area3D

@export_group("Damage")
@export var damage: float = 120.0
@export var player_damage_override: float = 30.0
@export var damage_type: Status.DamageType = Status.DamageType.GENERIC

@export_group("Knockback")
@export var knockback_force: float = 15.0
@export var knockup_force: float = 0.0

@export_group("Save Data")
@export var invoker: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_area_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_body_entered(body: Node3D) -> void:
	#var ray := PhysicsRayQueryParameters3D.create(global_position, body.global_position, collision_mask, [get_rid()])
	#var space_state = get_world_3d().direct_space_state
	#var hit := space_state.intersect_ray(ray)
	#if hit["collider"] != body:
		#return
	
	var d = player_damage_override if (body is Player or body.find_child("Status") is PlayerStatus) else damage
	#print("%s hit %s, who is %s for %s" % [name, body.name, body is Player or body.find_child("Status") is PlayerStatus, d])
	if body.has_node("Status"):
		body.find_child("Status").damage_typed(
				d,
				damage_type
		)
		if body and invoker and body is EnemyBase and body != invoker:
			body.detect_target(invoker, EnemyBase.DetectionType.RETALIATION)
	if body.has_method("apply_knockback"):
		body.apply_knockback(
			knockback_force * (body.global_position - global_position).normalized(),
			knockup_force
	)
	
