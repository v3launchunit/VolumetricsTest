class_name WeaponAltFire
extends WeaponBase


## A weapon that possesses two distinct fire modes.


@export_group("Secondary Fire", "alt_")
## The bullet shot by the secondary fire.
@export var alt_bullet: PackedScene
## The time, in seconds, that the player must wait after using this weapon's
## alt-fire before the weapon can be used again.
@export_range(0, 3, 0.01) var alt_shot_cooldown: float = 1.0
## The number of projectiles that should be instantiated per shot.
@export_range(1, 50, 1) var alt_volley: int = 1
## The maximum horizontal offset of the fired projectile(s), in degrees.
## Vertical spread is half this.
@export_range(0, 90, 0.1) var alt_spread: float = 0.0
@export var alt_inherit_velocity: bool = false

@export_subgroup("Secondary Ammo", "alt_ammo_")
## The name of the ammo pool this weapon draws from in order to fire.
@export var alt_ammo_type: String = "none"
## How much ammo must be consumed per shot.
@export var alt_ammo_cost: int = 1

## Where the secondary fire's bullets are fired from.
@onready var alt_spawner := find_child("AltSpawner") as Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	manager.switched_weapons.connect(_on_player_cam_switched_weapons)
	hud = find_parent("Player").find_child("HUD")
	hud_connected.connect(hud._on_weapon_hud_connected)
	hud_connected.emit(category, index, ammo_type, alt_ammo_type)
	state_machine.start("deploy", true)
#	var p = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if cooldown_timer > 0:
		#cooldown_timer -= delta
#
	#if refire_penalty > 0:
		#refire_penalty -= delta
#
	#if (
			#active and
			#(not safety_catch_active) and
			#Input.is_action_pressed("weapon_fire_main") and
			#cooldown_timer <= 0 and
			#manager.has_ammo(ammo_type, ammo_cost)
	#):
		#_fire()
#
	#if (
			#active and
			#(not safety_catch_active) and
			#cooldown_timer <= 0 and
			#Input.is_action_pressed("weapon_fire_alt") and
			#manager.has_ammo(alt_ammo_type, alt_ammo_cost)
	#):
		#_fire_alt()
#
	#if safety_catch_active and not (
			#Input.is_action_pressed("weapon_fire_main") or
			#Input.is_action_pressed("weapon_fire_alt")
	#):
		#safety_catch_active = false


func _deploy(with_safety_catch: bool = true) -> void:
	visible = true
	active = true
	safety_catch_active = use_safety_catch if with_safety_catch else false
	hud_connected.emit(category, index, ammo_type, alt_ammo_type)
	state_machine.start("deploy", true)


func _listen_for_input() -> bool:
	if super():
		return true
	if (
			Input.is_action_pressed("weapon_fire_alt") 
			and manager.has_ammo(alt_ammo_type, alt_ammo_cost)
	):
		_fire_alt()
		return true
	return false


func _fire_alt():
	var base_rotation = global_rotation
	var spawner_base_rotation = alt_spawner.global_rotation
	for v in alt_volley:
#		if manager.find_child("RayCast3D").is_colliding():
#			alt_spawner.look_at(manager.find_child("RayCast3D").get_collision_point())
#			alt_spawner.rotate_y(PI)
#		else:
		global_rotation = base_rotation
		alt_spawner.global_rotation = manager.global_rotation
		emit_bullet(alt_bullet, alt_inherit_velocity)

	global_rotation = base_rotation
	alt_spawner.global_rotation = spawner_base_rotation

	cooldown_timer = alt_shot_cooldown
	state_machine.start("alt_firing", true)
