extends EnemyBase

@export_category("EnemyFlying")

@export var target_min_distance: float = 5.0

@onready var floor_line: RayCast3D = find_child("FloorLine")


func _scan(delta) -> void:
	sight_line.rotation.y = sin(state_timer * sight_line_sweep_speed + randf() /
			sight_line_sweep_angle * 2) * sight_line_sweep_angle / 2
	sight_line.rotation.x = cos(state_timer * sight_line_sweep_speed + randf() /
			sight_line_sweep_angle * PI) * sight_line_sweep_angle / 2
	if sight_line.is_colliding() and sight_line.get_collider() is Player:
		detect_target(sight_line.get_collider())
		change_state(State.PURSUING)
	walk_vel = walk_vel.move_toward(Vector3.ZERO, acceleration * delta)
	nav_agent.set_velocity(walk_vel)


func _pursue(delta) -> void:
	if not check_target_validity(): # Make sure I actually have a target first
		change_state(State.IDLE) # Can't pursue a target that doesn't exist
		return

	if check_path_staleness():
		nav_agent.target_position = current_targets[-1].global_position

	# Casually approach target
	var next_pos: Vector3

	if can_see_target():
		next_pos = current_targets[-1].global_position
		sight_line.look_at(next_pos)
	else:
		next_pos = nav_agent.get_next_path_position()
		sight_line.look_at(next_pos)

	global_rotation.y = lerp_angle(
			global_rotation.y,
			sight_line.global_rotation.y,
			delta * turning_speed
	)

	walk_vel = walk_vel.move_toward(
			-speed * sight_line.global_transform.basis.z,
			acceleration * delta
	)

	if floor_line.is_colliding():
		walk_vel.y += jump_height

	if global_position.distance_to(
			current_targets[-1].global_position) < target_min_distance:
		walk_vel += jump_height * sight_line.global_transform.basis.z

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(walk_vel)
	else:
		velocity += walk_vel
		move_and_slide()

	# Decide if it's time to attack my target
	if check_attack_readiness(): #and sight_line.get_collider() == current_target:
		change_state(State.ATTACKING)


func _attack(delta) -> void:
	# Make sure my target still exists
	if current_targets.is_empty() or current_targets[-1] == null:
		change_state(State.IDLE)
		return

	look_at(current_targets[-1].global_position)
	walk_vel = walk_vel.move_toward(Vector3.ZERO, acceleration * delta)
	nav_agent.set_velocity(walk_vel)
	if state_timer >= attack_delay:
		do_attack()


#func _post_attack(delta) -> void:
#	walk_vel = walk_vel.move_toward(Vector3.ZERO, acceleration * delta)
#	nav_agent.set_velocity(walk_vel)


func _gravity(delta: float) -> Vector3:
	grav_vel = (
			Vector3.ZERO if is_on_floor() or current_state != State.DEAD 
			else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	)
	return grav_vel


#func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
#	pass
	
