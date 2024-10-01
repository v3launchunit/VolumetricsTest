extends EnemyAttackPattern


#@export var allow_pitch: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if "detect_mode" in properties and properties["detect_mode"] > 0:
		match properties["detect_mode"]:
			# 0: 00
				# blind = <don't override>
				# deaf = <don't override>
			1: # 01
				blind = false
				# deaf = <don't override>
			2: # 02
				blind = true
				# deaf = <don't override>
			3: # 10
				# blind = <don't override>
				deaf = false
			4: # 11
				blind = false
				deaf = false
			5: # 12
				blind = true
				deaf = false
			6: # 20
				# blind = <don't override>
				deaf = true
			7: # 21
				blind = false
				deaf = true
			8: # 22
				blind = true
				deaf = true

	if "tripwire_group" in properties and properties["tripwire_group"] != "none":
		for member in get_tree().get_nodes_in_group(properties["tripwire_group"]):
			if member.has_signal("interacted"):
				member.interacted.connect(detect_target)
		add_to_group(properties["tripwire_group"], true)
	
	match current_state:
		State.AMBUSHING:
			state_machine.start("ambush", true)
		State.IDLE:
			state_machine.start("idle", true)
		State.SEARCHING:
			state_machine.start("moving", true)
		State.PURSUING:
			state_machine.start("moving", true)
		State.ATTACKING:
			state_machine.start("attacking", true)
		State.POST_ATTACKING:
			pass
		State.FLINCHING:
			state_machine.start("flinching", true)
		State.FLEEING:
			state_machine.start("moving", true)
		State.DEAD:
			state_machine.start("dead", true)
		
	status.injured.connect(_on_status_injured)
	status.died.connect(_on_status_died)
	add_to_group(species)
	
	var level := get_tree().current_scene as Level
	if level and not level.loaded_from_savegame:
		level.foes += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	state_timer += delta
	velocity = _jump(delta) + _gravity(delta) + _knockback(delta)
	match current_state:
		State.AMBUSHING:
			if state_timer >= wake_up_time:
				change_state(
						State.IDLE 
						if current_targets.is_empty()
						else State.PURSUING
				)
				if not current_targets.is_empty():
					detect_target(current_targets[-1])
		State.IDLE:
			global_rotation = Quaternion(global_basis).slerp(
					Quaternion(get_parent_node_3d().global_basis), 
					delta * turning_speed
			).get_euler()
			_scan(delta)
		State.SEARCHING:
			_scan(delta)
		State.PURSUING:
			_pursue(delta)
		State.ATTACKING:
			_attack(delta)
		State.POST_ATTACKING:
			_post_attack(delta)
		State.FLINCHING:
			_flinch()
		State.FLEEING:
			pass
		State.DEAD:
			pass

	if check_target_validity() and current_targets[-1].get_node("Status").health <= 0:
		current_targets.pop_back()
		if current_targets.is_empty():
			change_state(State.IDLE)
			
	if not can_see_target():
		current_targets.pop_back()
		if current_targets.is_empty():
			change_state(State.IDLE)


func change_state(to: State):
	if current_state == State.DEAD or to == current_state:
		return
	match current_state:
		State.AMBUSHING:
			pass
		State.IDLE:
			sight_line.rotation.y = 0
		State.SEARCHING:
			sight_line.rotation.y = 0
		State.PURSUING:
			pass
		State.ATTACKING:
			pass
		State.POST_ATTACKING:
			pass
		State.FLINCHING:
			pass
		State.FLEEING:
			pass
		State.DEAD:
			pass
	match to:
		State.AMBUSHING:
			pass
		State.IDLE:
			sight_line.rotation.x = 0
			state_machine.travel("idle", true)
		State.SEARCHING:
			sight_line.rotation.x = 0
			state_machine.travel("moving", true)
		State.PURSUING:
			if nav_agent != null and check_target_validity():
				nav_agent.target_position = current_targets[-1].global_position
			state_machine.travel("moving", true)
		State.ATTACKING:
			pass
		State.POST_ATTACKING:
			pass
		State.FLINCHING:
			state_machine.travel("flinching", true)
			if check_target_validity():
				look_at(current_targets[-1].global_position)
		State.FLEEING:
			_to_fleeing()
		State.DEAD:
			audio_player.stream = death_stream
			audio_player.play()
			state_machine.travel("dead", true)

	walk_vel = Vector3.ZERO
	if nav_agent != null:
		nav_agent.set_velocity(Vector3.ZERO)
	current_state = to
	state_timer = 0


func _pursue(delta) -> void:
	if not check_target_validity(): # Make sure I actually have a target first
		#change_state(State.IDLE) # Can't pursue a target that doesn't exist
		return

	sight_line.look_at(current_targets[-1].global_position)
	global_rotation = Quaternion(global_basis).slerp(Quaternion(sight_line.global_basis), clampf(delta * turning_speed, 0, 1)).get_euler()

	# Decide if it's time to attack my target
	if check_attack_readiness():
		_begin_attack()


func _begin_attack() -> void:
	if pattern_selection_mode == PatternSelectionMode.SEQUENTIAL:
		current_pattern += 1
		if current_pattern >= patterns.size():
			current_pattern = 0
	state_machine.travel(patterns[current_pattern].animation, true)
	change_state(State.ATTACKING)


func _flinch() -> void:
	if state_timer >= flinch_time:
		change_state(State.PURSUING)


func _attack(_delta: float) -> void:
	sight_line.look_at(current_targets[-1].global_position)
	global_rotation = Quaternion(global_basis).slerp(Quaternion(sight_line.global_basis), clampf(_delta * turning_speed, 0, 1)).get_euler()
	super(_delta)


func do_attack() -> void:
	var current_bullet: PackedScene = patterns[current_pattern].bullet
	var current_volley: int = patterns[current_pattern].volley
	var current_spread: float = patterns[current_pattern].spread
	var current_spawner: Node3D = (
			spawner if patterns[current_pattern].spawners.is_empty()
			else get_node(patterns[current_pattern].spawners[0])
	)
	var current_spawner_index: int = (
			-1 if patterns[current_pattern].spawners.is_empty()
			else 0
	)

	var spawner_base_rotation: Vector3 = current_spawner.global_rotation
	for v in current_volley:
		current_spawner.global_rotation = spawner_base_rotation
		current_spawner.rotate_z(deg_to_rad(randf_range(-current_spread/2, current_spread/2)))
		current_spawner.rotate_y(deg_to_rad(randf_range(-current_spread/4, current_spread/4)))

		var instance: Node3D = current_bullet.instantiate()
		current_spawner.add_child(instance)
		instance.reparent(get_tree().current_scene)
		if instance is PhysicsBody3D:
			instance.add_collision_exception_with(self)
			add_collision_exception_with(instance)
			if instance is HomingRocket:
				instance.target = current_targets[-1]
		if instance is Hitscan:
			instance.query_origin = global_position
			instance.exceptions.append(self)
		instance.invoker = self

		current_spawner.global_rotation = spawner_base_rotation
		if current_spawner_index >= 0:
			current_spawner_index += 1
			if current_spawner_index >= patterns[current_pattern].spawners.size():
				current_spawner_index = 0
			current_spawner = get_node(patterns[current_pattern].spawners[current_spawner_index])

	current_burst += 1
	if current_burst >= patterns[current_pattern].burst:
		change_state(State.POST_ATTACKING)
		current_burst = 0
