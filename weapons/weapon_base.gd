class_name WeaponBase
extends Node3D


## Base class for [Player]-owned weaponry.


#signal recoiled(amount: Vector3)
signal hud_connected(category: int, index: int, ammo_type: String, alt_ammo_type: String)

#@export_category("Weapon")

@export_group("Primary Fire")
## The scene that is instantiated when this weapon is fired.
@export var bullet: PackedScene
## The time, in seconds, that the player must wait after firing this weapon
## before they can fire it again.
@export_range(0, 3, 0.01) var shot_cooldown: float = 1.0
## The number of projectiles that should be instantiated per shot.
@export_range(1, 50, 1) var volley: int = 1
## The maximum horizontal offset of the fired projectile(s), in degrees.
## Vertical spread is half this.
@export_range(0, 90) var spread: float = 0.0
## The amount of backwards force that will be imparted onto the player when this 
## weapon is fired.
@export var recoil: float = 0.0
@export_range(
		-180.0,
		180.0,
		0.1,
		"or_less",
		"or_greater",
		"radians"
) var cam_recoil: float = PI / 36.0
@export var inherit_velocity: bool = false

@export_subgroup("Primary Ammo", "ammo_")
## The name of the ammo pool this weapon draws from in order to fire.
@export var ammo_type: String = "none"
## The amount of ammo consumed per shot.
@export var ammo_cost: int = 1
## Whether this weapon is affected by the "berserk" powerup.
@export var apply_berserk: bool = false
## If use_safety_catch is enabled, when the player switches to this weapon while
## holding the "fire" button, they will be prevented from firing until the
## "fire" button is released, so as to not waste ammo and/or blow onself up with
## an explosive weapon in close quarters.
@export var use_safety_catch: bool = true

#@export var anti_clip_distance: float = 0

@export_group("Sorting")
## The category where this weapon is stored. Categories 0-6 correspond to the
## top-row number keys 1-7.
@export_range(0, 6, 1) var category: int = 0
## The position this weapon inhabits within its category. Affects the order in
## which weapons are selected.
@export var index: int = 0

@export_group("Save Data")
## Holdover from before I knew what a "process mode" was. Will probably stick
## around forever.
@export var active: bool = true
## How long this weapon has left before it can do things again.
@export var cooldown_timer: float = 0.0 # seconds

## Set to 1.0 when a bullet is instantiated (i.e. only applied to the first
## bullet in a given volley), and decays back to 0.0 over the course of one
## second. The spread of any given bullet is multiplied by this. [br] In
## essence, this variable ensures that the first bullet fired from a weapon
## will always be accurate.
var refire_penalty: float = 0.0
var safety_catch_active: bool = false
var hud: HudHandler

## This node's global position is used to determine where the weapon's
## projectile(s) will be fired from.
@onready var spawner := find_child("Spawner") as Node3D
## This weapon's [AnimationTree].
@onready var anim_tree := find_child("AnimationTree") as AnimationTree
## The [AnimationNodeStateMachinePlayback] associated with this weapon's [AnimationTree].
@onready var state_machine := anim_tree.get(
		"parameters/playback") as AnimationNodeStateMachinePlayback
@onready var manager := find_parent("PlayerCam") as WeaponManager
@onready var eject_sys := find_child("ShellEject") as GPUParticles3D
## The [Player] who owns this weapon.
@onready var player := find_parent("Player") as Player
#@onready var alert_area: Area3D = get_node_or_null("AlertRadius")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manager.switched_weapons.connect(_on_player_cam_switched_weapons)
	hud = find_parent("Player").find_child("HUD") as HudHandler
	hud_connected.connect(hud._on_weapon_hud_connected)
	state_machine.start("deploy", true)
#	bullet_scene = load(bullet)
#	hud_connected.emit(ammo_type, "none")
#	recoiled.connect(p.get_parent().get_script().apply_knockback)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta * (player.status.ff_timers.size() + 1)

	if refire_penalty > 0:
		refire_penalty -= delta

	if active and not safety_catch_active and cooldown_timer <= 0:
		_listen_for_input()
	
	if safety_catch_active and not (Input.is_action_pressed("weapon_fire_main") 
			or Input.is_action_pressed("weapon_fire_alt")):
		safety_catch_active = false


#func _unhandled_input(_event: InputEvent) -> void:


## Called whenever the player switches weapons.
func _on_player_cam_switched_weapons(c, i, catch) -> void:
	if c == category and i == index:
		_deploy(catch)
	else:
		_holster()


## Called when this weapon is selected.
func _deploy(with_safety_catch: bool = true) -> void:
	visible = true
	active = true
	safety_catch_active = use_safety_catch if with_safety_catch else false
	hud_connected.emit(category, index, ammo_type, "none")
	state_machine.start("deploy", true)


## Called when any weapon besides this one is selected.
func _holster() -> void:
	visible = false
	active = false


func _listen_for_input() -> bool:
	if (
			Input.is_action_pressed("weapon_fire_main") 
			and manager.has_ammo(ammo_type, ammo_cost)
	):
		_fire()
		return true
	if (
			anim_tree.tree_root is AnimationNodeStateMachine
			and (anim_tree.tree_root as AnimationNodeStateMachine).has_node("flourish")
			and Input.is_action_just_pressed("weapon_flourish")
	):
		state_machine.travel("flourish")
	return false


## Fires the weapon.
func _fire() -> void:
	var base_rotation = rotation
	var spawner_base_rotation = spawner.global_rotation
	for v in volley:
		rotation = base_rotation
		emit_bullet(bullet, inherit_velocity)

	rotation = base_rotation
	spawner.global_rotation = spawner_base_rotation

	if abs(recoil) > Globals.C_EPSILON:
#		recoiled.emit(Vector3.BACK * recoil)
		player.apply_knockback(recoil * get_global_transform().basis.z * -1)

	if abs(cam_recoil) > deg_to_rad(Globals.C_EPSILON):
		player.cam_recoil_pos += cam_recoil

	cooldown_timer = shot_cooldown
	if eject_sys != null:
		eject_sys.emit_particle(eject_sys.transform, transform.basis.z * Vector3.LEFT, \
				Color.WHITE, Color.WHITE, 0)
	state_machine.start("firing", true)
	#instance.AddCollisionExceptionWith(get_parent().get_parent())


## Instantiates a single bullet from a [PackedScene], and returns the resulting [Node].
func emit_bullet(what: PackedScene, inherit_vel: bool = false) -> Node:
#	if manager.find_child("RayCast3D").is_colliding():
#		spawner.look_at(manager.find_child("RayCast3D").get_collision_point())
#		spawner.rotate_y(PI)
#	else:
	spawner.global_rotation = manager.global_rotation
	rotate_y(deg_to_rad(randf_range(-spread/2, spread/2) * refire_penalty))
	rotate_x(deg_to_rad(randf_range(-spread/4, spread/4) * refire_penalty))
	refire_penalty = 1.0

	var instance := what.instantiate() as Node3D
	spawner.add_child(instance)
	if apply_berserk and "damage" in instance:
		instance.damage *= 10
	if inherit_vel and instance is Bullet:
		(instance as Bullet).linear_velocity = (
				-(instance as Bullet).speed 
				* (instance as Bullet).global_transform.basis.z.normalized()
				+ player.velocity
		)
	elif instance is Hitscan:
		instance.query_origin = manager.global_position
	instance.reparent(get_tree().current_scene)
	instance.scale = Vector3.ONE
	instance.invoker = manager.find_parent("Player")
	return instance
