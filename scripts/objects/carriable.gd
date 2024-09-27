class_name Carriable
extends RigidBody3D


signal grabbed(what: Carriable)
signal released

@export var hold_max_distance_squared: float = 9.0
@export var throw_speed: float = 1.0
@export var throw_damage: float = 100.0
@export var throw_self_damage: float = 10.0

var holder: Player = null


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if holder != null and Input.is_action_just_pressed("weapon_fire_main"):
		pass
	if holder != null and (
			Input.is_action_just_pressed("interact")
			or global_position.distance_squared_to(holder.global_position)
					> hold_max_distance_squared
	):
		pass


func _physics_process(_delta: float) -> void:
	pass


func interact(body: Player) -> void:
	if not grabbed.is_connected(body._on_carriable_grabbed):
		grabbed.connect(body._on_carriable_grabbed)
	if holder == null:
		holder = body

