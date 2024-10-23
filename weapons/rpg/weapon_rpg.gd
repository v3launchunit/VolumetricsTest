class_name WeaponRPG
extends WeaponAltFire

## Rocket launcher weapon class.

## A special version of [WeaponAltFire] meant for the RPG, that can only fire one 
## primary-fire projectile at a time.

## The projectile associated with this weapon.
@export_storage var instance: Node = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if state_machine.get_current_node() == "empty":
		if instance == null and manager.has_ammo(ammo_type, 1, true):
			state_machine.travel("reloading")
			cooldown_timer = shot_cooldown
		else:
			cooldown_timer = 1000.0


func _fire() -> void:
	var base_rotation = rotation
	var spawner_base_rotation = spawner.global_rotation
	#for v in volley:
	#rotation = base_rotation
	instance = emit_bullet(bullet)
	rotation = base_rotation
	spawner.global_rotation = spawner_base_rotation

	if abs(recoil) > Globals.C_EPSILON:
		player.apply_knockback(recoil * get_global_transform().basis.z * -1)
	if abs(cam_recoil) > deg_to_rad(Globals.C_EPSILON):
		player.cam_recoil_pos += cam_recoil

	cooldown_timer = shot_cooldown
	#if eject_sys != null:
		#eject_sys.emit_particle(eject_sys.transform, transform.basis.z * Vector3.LEFT, \
				#Color.WHITE, Color.WHITE, 0)
	state_machine.start("firing", true)
