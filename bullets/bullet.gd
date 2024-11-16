class_name Bullet extends RigidBody3D


## The speed with which this bullet travels.
@export_range(0.0, 100.0, 0.1, "or_greater") var speed: float = 10
## The amount of damage that this bullet deals upon contact.
@export_range(0.0, 1000.0, 0.1, "or_greater") var damage: float = 10
@export var player_damage_multiplier: Array[float] = [0.75, 1.0, 1.5, 2.0]
@export var damage_type: Status.DamageType = Status.DamageType.GENERIC
## The scene that is instantiated when this bullet object contacts a surface.
@export var explosion: PackedScene
## If set to "true", then the explosion set above will be parented to the
## contacted surface. Otherwise, it will be parented to the root node's third
## child.
@export var sticky: bool = false
@export var bouncy: bool = false
## If set to "true" and this bullet kills the entity it impacts, it will
## have its damage reduced and continue to travel until it impacts something
## it cannot. Otherwise, this bullet is deleted as soon as it contacts any
## surface.
@export var piercer: bool = true
## The base knockback force this bullet imparts onto whatever surface it
## contacts.
@export_range(0.0, 100.0, 0.1, "or_greater") var knockback_force: float = 1.0

@export_group("Save Data")
@export var invoker: Node3D

#@onready var explosion_scene: PackedScene = load(explosion)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if linear_velocity == Vector3.ZERO:
		linear_velocity = -speed * global_transform.basis.z.normalized()
#	add_collision_exception_with(get_node("Player"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if piercer and linear_velocity != -speed * global_transform.basis.z.normalized():
		linear_velocity = -speed * global_transform.basis.z.normalized()
#	if body_entered:
#		print("bullet collided")
#		queue_free()


func _on_body_entered(body: Node) -> void:
	if bouncy and body is not EnemyBase:
		return
	var e: Node3D
	if explosion != null:
		e = explosion.instantiate()
		add_child(e)
		e.reparent(body if sticky else get_tree().current_scene)
		if e is LodgedNail or e is LodgedHarpoon:
			e.invoker = invoker
		for child in e.get_children():
			if child is AreaDamage:
				child.invoker = invoker

	if body.name != "Shield" and body.has_node("Status"):
		var status = body.find_child("Status")
		damage -= status.damage_typed(damage * (
				player_damage_multiplier[Globals.s_difficulty]
				if status is PlayerStatus
				else 1.0
		), damage_type)
		if body.has_method("detect_target") and invoker != null and invoker != body:
			body.detect_target(invoker, EnemyBase.DetectionType.RETALIATION)
			body.apply_knockback(
					knockback_force * (
							body.global_position -
							global_position
					).normalized()
			)
		if not piercer or damage <= 0:
			queue_free()
		else:
			add_collision_exception_with(body)
			linear_velocity = speed * global_transform.basis.z.normalized()
	else:
		queue_free()
