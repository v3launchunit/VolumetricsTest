class_name Carriable
extends RigidBody3D


#signal grabbed(what: Carriable)
#signal released

@export var hold_max_distance_squared: float = 9.0
@export var throw_speed: float = 20.0
@export var throw_damage: float = 100.0
@export var throw_self_damage: float = 10.0

var holder : Player = null
var hold_pos : Node3D = null
var input_fudge : bool = false
var thrown : bool = false


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = max(max_contacts_reported, 1)
	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	if hold_pos != null and Input.is_action_just_pressed("weapon_fire_main"):
		hold_pos = null
		holder.holding_something = false
		freeze = false
		thrown = true
		apply_impulse(-Vector3(holder.camera.global_basis.z) * throw_speed)
		await get_tree().physics_frame
		remove_collision_exception_with(holder)
		holder = null
	if hold_pos != null and not input_fudge and (
			Input.is_action_just_pressed("interact")
			or global_position.distance_squared_to(hold_pos.global_position)
					> hold_max_distance_squared
	):
		hold_pos = null
		holder.holding_something = false
		freeze = false
		#apply_impulse(Vector3(holder.velocity.x, 0.0, holder.velocity.z))
		await get_tree().physics_frame
		remove_collision_exception_with(holder)
		holder = null
	if input_fudge and Input.is_action_just_released("interact"):
		input_fudge = false


func _physics_process(_delta: float) -> void:
	if hold_pos != null:
		#apply_central_force((global_position - hold_pos.global_position))
		global_position = global_position.lerp(hold_pos.global_position, 0.5 + _delta * 10.0)


func interact(body: Player) -> void:
	Console.print_line("picked up object")
	#if not grabbed.is_connected(body._on_carriable_grabbed):
		#grabbed.connect(body._on_carriable_grabbed)
	#grabbed.emit(self)
	if holder == null:
		#Console.print_line("%s" % holder)
		holder = body
		#Console.print_line("%s" % holder)
		holder.was_holding_something = true
		holder.holding_something = true
		hold_pos = holder.find_child("HoldPoint")
		freeze = true
		add_collision_exception_with(holder)
		input_fudge = true


func _on_body_entered(body: Node3D) -> void:
	if thrown and body is not Player:
		thrown = false
		if body.has_node("Status"):
			(body.get_node("Status") as Status).damage(throw_damage)
		if has_node("Status"):
			(get_node("Status") as Status).damage(throw_self_damage)
