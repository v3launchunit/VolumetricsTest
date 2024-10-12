extends WeaponBase

@export_category("Crossbow")

## The amount of time it takes, in seconds, for the power of the charging shot
## to increment.
@export var charge_tick_delay: float = 0.1

var charging: bool = false
var charge_timer: float = 0
var banked_charges: int = 0


func _process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta * (player.status.ff_timers.size() + 1)

	if charging:
		charge_timer += delta
		while charge_timer >= charge_tick_delay:
			charge_timer -= charge_tick_delay
			if (
					not (manager.has_ammo(ammo_type) and
					active and
					Input.is_action_pressed("weapon_fire_main"))
			):
				_fire()
				banked_charges = 0
				charge_timer = 0
				charging = false
				return
			else:
				banked_charges += 1
	elif (
			active and
			(not safety_catch_active) and
			Input.is_action_pressed("weapon_fire_main") and
			cooldown_timer <= 0
			and manager.has_ammo(ammo_type, ammo_cost, true)
	):
		charging = true
		state_machine.start("charging", true)

	if safety_catch_active and not Input.is_action_pressed("weapon_fire_main"):
		safety_catch_active = false


func _fire() -> void:
	var base_rotation = global_rotation
	var spawner_base_rotation = spawner.global_rotation
	for v in volley:
#		if manager.find_child("RayCast3D").is_colliding():
#			spawner.look_at(manager.find_child("RayCast3D").get_collision_point())
#			spawner.rotate_y(PI)
#		else:
		global_rotation = base_rotation
		spawner.global_rotation = manager.global_rotation
		rotate_y(deg_to_rad(randf_range(-spread/2, spread/2)))
		rotate_x(deg_to_rad(randf_range(-spread/4, spread/4)))

		var instance = bullet.instantiate()
		spawner.add_child(instance)
		if instance is Hitscan:
			instance.query_origin = manager.global_position
		instance.reparent(get_tree().root.get_child(2))
		instance.damage *= banked_charges
		instance.invoker = manager.find_parent("Player")

	global_rotation = base_rotation
	spawner.global_rotation = spawner_base_rotation

	if recoil != 0:
#		recoiled.emit(Vector3.BACK * recoil)
		var p: Player = find_parent("Player")
		p.apply_knockback(recoil * get_global_transform().basis.z * -1)

	cooldown_timer = shot_cooldown
	if eject_sys != null:
		eject_sys.emit_particle(
				eject_sys.transform,
				transform.basis.z * Vector3.LEFT,
				Color.WHITE,
				Color.WHITE,
				0
		)
	state_machine.start("firing", true)
