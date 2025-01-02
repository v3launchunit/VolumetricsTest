class_name EnemyBase extends CharacterBody3D

enum State {
	## Busy spawning in and can't do anything. Meant to prevent the enemy from
	## instantly targeting the player and ruining all my hard work on the ambush
	## animations.
	AMBUSHING,
	## Does not have a target, or really anything else to do.
	IDLE,
	## Moving towards some detected event, but does not have any targets.
	## [br]Currently unused.
	SEARCHING,
	## Pursuing the current target.
	PURSUING,
	ATTACKING, ## Firing at target.
	## Recovering after firing at target. Separate from [enum State.ATTACKING]
	## for the sake of only needing to keep track of one timer that tracks how
	## long the node has been in a given state.
	POST_ATTACKING,
	## Unable to move due to flinching from an attack.
	FLINCHING,
	## Move away from targets instead of towards them. Mostly for lizards.
	FLEEING,
	## Self-explanatory.
	DEAD,
}

enum DetectionType {
	## For when the enemy just magically knows where you are
	INSTINCT,
	## For when the enemy sees you
	SIGHT,
	## For when the enemy hears you
	SOUND,
	## For when the enemy got hit by you
	RETALIATION,
}

@export var species: StringName

@export var properties: Dictionary = {}

@export_group("Movement")
@export var turret_mode: bool = false
## The base movement speed of this enemy.
@export_range(1, 35, 0.1, "or_greater") var speed: float = 10.0
## The speed at which this enemy is able to reorient itself.
@export_range(1, 35, 0.1, "or_greater") var turning_speed: float = 10.0
## The rate at which this enemy goes from standing still to moving at full
## speed.
@export_range(10, 400, 0.1) var acceleration: float = 100.0
## An intensity multiplier for incoming knockback.
@export_range(0, 1, 0.001, "or_greater") var knockback_multiplier: float = 1.0
## The rate at which the velocity imparted by knockback "decays" towards zero.
@export var knockback_drag: float = 10.0
## Self-explanatory.
@export_range(0.0, 3.0, 0.1, "or_greater") var jump_height: float = 0.0
#@export var target_pos_offset: Vector3 = Vector3.ZERO
@export var wanderer: bool = false

@export_group("Detection")
@export var hunts_player: bool = true
@export var hunts_species: Array[StringName] = []
## If enabled, prevents sight-based detection.
@export var blind: bool = false
## If enabled, prevents sound-based detection.
@export var deaf: bool = false
## Will this enemy infight with other enemies?
@export var infighter: bool = true
## The delay, in seconds, between this enemy being added to the [SceneTree] and
## becoming active.
@export var wake_up_time: float = 3.0
## The "field of view" of this enemy - essentially, how far away from its
## current orientation it can spot the player while idle.
@export_range(0, 360, 1, "radians") var sight_line_sweep_angle: float = (2 * PI) / 3
## The speed with which this enemy scans for targets, expressed as the number
## of full sweeps that occur every PI seconds.
@export_range(0, 10, 0.1, "or_greater") var sight_line_sweep_speed: float = 3
#@export var enemies: Array[String] = ["Player"]
## The sound that plays when this enemy first detects a target while idle.
@export var detection_stream: AudioStream

@export_group("Pathing")
@export var player_target_offset := Vector3.ZERO
@export var proximity_coefficient: float = 1
@export var line_of_sight_value: float = 10
@export var old_dest_bias: float = 5

@export_group("Combat")
## The minimum time, in seconds, that this enemy must spend moving before
## making an attack. The actual interval varies randomly between this value
## and attack_interval + 1.
@export_range(0.0, 10.0, 0.01, "or_greater") var attack_interval: float = 3.0
## The absolute furthest away this enemy can be from its target and still be
## able to attack.
@export_range(0.0, 64.0, 0.1, "or_greater") var attack_range: float = 256.0
## If this enemy's target is within this range, the waiting time from
## attack_interval will be skipped.
@export_range(0.0, 10.0, 0.1, "or_greater") var melee_range: float = 2.0
## The amount of time, in seconds, between when the attack animation begins
## and the attack's associated projectile(s) actually spawn.
@export_range(0.0, 1.0, 0.01, "or_greater") var attack_delay: float = 0.5
## The amount of time after spawning an attack's projectile(s) before this enemy
## can begin moving again.
@export_range(0.0, 1.0, 0.01, "or_greater") var attack_recovery_time: float = 0.25
## The projectile(s) fired when this enemy attacks its target.
@export var bullet: PackedScene
## The number of projectiles that should be fired per attack.
@export var volley: int = 1
## The maximum horizontal offset of the attack's projectile(s), in degrees.
## Vertical spread is half this.
@export_range(0.0, 180.0, 0.1, "degrees") var spread: float = 0.0
## The enemy's current known targets, in ascending order of priority.
@export var current_targets: Array[PhysicsBody3D]
@export_subgroup("Nightmare")
## Alternate bullet used by this enemy in NIGHTMARE mode. Defaults to [member bullet].
@export var nightmare_bullet: PackedScene

@export_group("Damage")
## The percent chance that this enemy will flinch and stop moving per incoming
## damage instance (NOT health lost).
@export_range(0.0, 1.0, 0.001) var flinch_chance: float = 0.1
## The amount of time after a flinch is triggered before this enemy can begin
## moving again.
@export_range(0.0, 10.0, 0.01, "or_greater") var flinch_time: float = 1.0
## How likely this enemy is to induce fleeing.
@export_range(0.0, 1.0, 0.01) var flee_chance: float = 0.0
## The sound that plays when this enemy dies.
@export var death_stream: AudioStream
@export var edible: bool = true
@export var eat_tooltip: String = "eat.corpse"
@export var corpse_food_value: float = 10.0
@export var eat_text: String = "pickup.health.gen"
@export var eat_flash_color := Color.GREEN

@export_group("Save Data")
@export var current_state: State = State.AMBUSHING
@export var current_destination: Vector3
@export var current_dest_score: float
@export var wander_idling: bool = false
@export var wander_idle_timer: float = 0.0
@export var wander_dir: float = 0.0
@export var jumping: bool = false
@export var walk_vel := Vector3.ZERO # Walking velocity
@export var safe_walk_vel := Vector3.ZERO
@export var grav_vel := Vector3.ZERO # Gravity velocity
@export var jump_vel := Vector3.ZERO # Jumping velocity
@export var knockback_vel := Vector3.ZERO # Knockback velocity
@export var state_timer: float = 0.0 ## How long I've been in my current state, in seconds

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var sees_player: bool = false
var path_re_eval_distance_squared
var sight_line_sweep_dot: float = cos(sight_line_sweep_angle / 2.0)

@onready var nav_agent: NavigationAgent3D = find_child("NavigationAgent3D")
@onready var nav_region := get_tree().current_scene.find_child(
		"NavigationRegion3D") as NavigationRegion3D
@onready var sight_line: RayCast3D = find_child("SightLine")
@onready var status: Status = find_child("Status")

@onready var spawner: Node3D = find_child("Spawner")
@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get(
		"parameters/playback")
@onready var attack_range_squared = attack_range * attack_range
@onready var melee_range_squared = melee_range * melee_range
@onready var audio_player: AudioStreamPlayer3D = find_child("AudioStreamPlayer3D")


func _ready() -> void:
	turret_mode = properties.get("turret_mode", false)
	
	path_re_eval_distance_squared = (
			$NavigationAgent3D.target_desired_distance
			* $NavigationAgent3D.target_desired_distance
	)
	
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
	
	if properties.get("corpse", false):
		current_state = State.DEAD
		if status.health > 0:
			status.health = 0
	
	match current_state:
		State.AMBUSHING:
			state_machine.start("ambush", true)
		State.IDLE:
			state_machine.start("idle", true)
		State.SEARCHING:
			state_machine.start("standby" if turret_mode else "moving", true)
		State.PURSUING:
			state_machine.start("standby" if turret_mode else "moving", true)
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
	nav_agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)
	add_to_group(species)
	
	var level := get_tree().current_scene as Level
	if level and not level.loaded_from_savegame:
		level.foes += 1


#func _process(delta: float) -> void:
	#($AnimationTree as AnimationTree).active = is_visible_in_tree()


func _physics_process(delta: float) -> void:
	rotation.x = 0
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
					detect_target(current_targets[-1], DetectionType.RETALIATION)
		State.IDLE:
			if wanderer:
				_wander(delta)
			_scan(delta)
		State.SEARCHING:
			_investigate(delta)
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
			_flee(delta)
		State.DEAD:
			pass

	if check_target_validity() and current_targets[-1].get_node("Status").health <= 0:
		current_targets.pop_back()
		if current_targets.is_empty():
			change_state(State.IDLE)

	move_and_slide()


# In case I need/want to do stuff with state transitions
# (probably where I'll handle animations & shit)
func change_state(to: State):
	rotation.x = 0
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
			state_machine.travel("standby" if turret_mode else "moving", true)
		State.PURSUING:
			if nav_agent != null and check_target_validity():
				nav_agent.target_position = current_targets[-1].global_position
			state_machine.travel("standby" if turret_mode else "moving", true)
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


func hear_target(target: Node3D) -> void:
	print(target.name)
	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
			global_position,
			target.global_position,
			collision_mask,
	)
	query.exclude = [get_rid()]
	var hit: Dictionary = space_state.intersect_ray(query)
	#print(hit)
	if (hit and hit["collider"] == target):
		detect_target(target)


func detect_target(target: Node3D, via := DetectionType.INSTINCT) -> void:
	if (
			# busy waking up
			current_state == State.AMBUSHING
			# busy flinching
			or current_state == State.FLINCHING
			# busy being dead
			or current_state == State.DEAD
			or (
					via == DetectionType.RETALIATION 
					and not (
							infighter 
							# retaliate against player regardless of infighting tendency
							or (target is Player and hunts_player) 
					)
			)
	):
		return
	if current_targets.is_empty(): # Only play detect sound if idle
		audio_player.stream = detection_stream
		audio_player.play()
	current_targets.append(target)
	if current_state == State.IDLE or current_state == State.SEARCHING:
		change_state(State.PURSUING)


func _wander(delta) -> void:
	if wander_idling:
		if wander_idle_timer < Globals.C_EPSILON:
			wander_idling = false
			#current_destination = NavigationServer3D.region_get_random_point(
					#nav_region.get_rid(),
					#nav_agent.navigation_layers,
					#false
			#)
			#nav_agent.target_position = current_destination
			wander_dir = randf_range(0, 2 * PI)
			state_machine.travel("moving", true)
			wander_idle_timer = randf_range(0.0, Globals.C_MAX_WANDER_MOVE_TIME)
		#var next_pos: Vector3 = nav_agent.get_next_path_position()
		#sight_line.look_at(next_pos)
	else:
		global_rotation.y = lerp_angle(
				global_rotation.y,
				wander_dir,
				delta * turning_speed
		)
		walk_vel = walk_vel.move_toward(-speed * transform.basis.z, acceleration * delta)
		if is_on_wall() or wander_idle_timer < Globals.C_EPSILON:
			state_machine.travel("idle", true)
			wander_idling = true
			wander_idle_timer = randf_range(0.0, Globals.C_MAX_WANDER_IDLE_TIME)
		elif nav_agent.avoidance_enabled:
			nav_agent.set_velocity(walk_vel)
		else:
			velocity += walk_vel
	wander_idle_timer -= delta


func _scan(_delta) -> void:
	if blind or randi_range(0, 5) != 0:
		return
	#sight_line.rotation.y = sin(
			#state_timer * sight_line_sweep_speed
			#+ randf() / sight_line_sweep_angle * 2
	#) * sight_line_sweep_angle / 2
	#var target_pool: Array[Node] = []
	#if hunts_player:
		#target_pool.append(get_tree().get_first_node_in_group("players"))
	#for prey in hunts_species:
		#target_pool.append_array(get_tree().get_nodes_in_group(prey))
	var target: Node3D = get_tree().get_first_node_in_group("players") as Node3D
	if target == null:
		print("no player")
		return
	
	# can't see target from behind
	if global_basis.z.normalized().dot((global_position - target.global_position).normalized()) < sight_line_sweep_dot:
		return
	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
			global_position,
			target.global_position,
			collision_mask,
	)
	query.exclude = [get_rid()]
	var hit: Dictionary = space_state.intersect_ray(query)
	#print(hit)
	if (hit and hit["collider"] == target):
		detect_target(target, DetectionType.SIGHT)
		change_state(State.PURSUING)
	#nav_agent.set_velocity(Vector3.ZERO)


func _investigate(delta) -> void:
	if randf() < Globals.C_PATH_RE_EVAL_CHANCE:
		nav_agent.target_position = current_destination
#	look_at(nav_agent.get_next_path_position())
#	rotation.x = 0
	global_rotation.y = lerp_angle(global_rotation.y,
			sight_line.global_rotation.y, delta * turning_speed)
	walk_vel = walk_vel.move_toward(
			-speed * transform.basis.z,
			acceleration * delta
	)
#	velocity += walk_vel
	nav_agent.set_velocity(walk_vel)
	velocity += safe_walk_vel
	if nav_agent.is_target_reached():
		change_state(State.IDLE)


func _pursue(delta) -> void:
	if not check_target_validity(): # Make sure I actually have a target first
		#change_state(State.IDLE) # Can't pursue a target that doesn't exist
		return

	if turret_mode:
		if is_on_floor():
			sight_line.look_at(current_targets[-1].global_position)
			global_rotation.y = lerp_angle(
					global_rotation.y,
					sight_line.global_rotation.y,
					delta * turning_speed
			)
	
	else:
		current_destination = (
				current_targets[-1].global_position 
				+ player_target_offset 
				* current_targets[-1].global_basis.z.normalized()
		)
		#current_destination = get_current_destination()

		if check_path_staleness(): # Make sure my target is still where I think it is
			nav_agent.target_position = current_destination

		# Casually approach target
		var next_pos: Vector3 = nav_agent.get_next_path_position()
		if is_on_floor():
			sight_line.look_at(next_pos)
			global_rotation.y = lerp_angle(
					global_rotation.y,
					sight_line.global_rotation.y,
					delta * turning_speed
			)
			walk_vel = walk_vel.move_toward(-speed * transform.basis.z, acceleration * delta)
		if nav_agent.avoidance_enabled:
			nav_agent.set_velocity(walk_vel)
		else:
			velocity += walk_vel

	# Decide if it's time to attack my target
	if check_attack_readiness():
		_begin_attack()


func check_target_validity() -> bool:
	return not (current_targets.is_empty() or current_targets[-1] == null)


func check_path_staleness() -> bool:
	return (
			(
					randf() < Globals.C_PATH_RE_EVAL_CHANCE
					or nav_agent.is_navigation_finished()
			)
			and nav_agent.target_position.distance_squared_to(
					current_destination) > path_re_eval_distance_squared
		)


func get_current_destination() -> Vector3:
	var destination: Vector3
	match randi_range(0, 1):
		0: # Current target's exact position
			destination = current_targets[-1].global_position
		1: # Completely random position
			destination = NavigationServer3D.region_get_random_point(
					nav_region.get_rid(),
					nav_agent.navigation_layers,
					false
			)
	var new_dest_score = rank_point(destination)
	if new_dest_score > current_dest_score + old_dest_bias:
		current_dest_score = new_dest_score
		return destination
	else:
		return current_destination


func rank_point(point: Vector3) -> float:
	var score: float = 0.0
	if not is_equal_approx(proximity_coefficient, 0.0):
		score += point.distance_squared_to(
				current_targets[-1].global_position) * proximity_coefficient
	if not blind and not is_equal_approx(line_of_sight_value, 0.0):
		var space_state = get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(
				point,
				current_targets[-1].global_position,
				collision_mask,
		)
		var hit: Dictionary = space_state.intersect_ray(query)
		if hit and hit.get("collider") == current_targets[-1]:
			score += line_of_sight_value
	return score


func check_attack_readiness() -> bool:
	return (
			current_targets[-1].global_position.distance_squared_to(global_position)
			< melee_range_squared 
			or (
					(state_timer * (4 if turret_mode else 1) >= attack_interval + randf()) 
					and current_targets[-1].global_position.distance_squared_to(global_position)
					< attack_range_squared 
					and can_see_target()
			)
		) #and sight_line.get_collider() == current_target:


func can_see_target() -> bool:
	if not is_inside_tree() or current_targets.is_empty() or current_targets[-1] == null:
		return false
	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
			global_position,
			current_targets[-1].global_position,
			collision_mask,
	)
	query.exclude = [get_rid()]
	var hit: Dictionary = space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == current_targets[-1]


func should_jump() -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = SphereShape3D.new()
	query.transform = global_transform
	query.transform.origin += transform.basis.z
	query.transform.origin -= Vector3(0, -0.25, 0)
	query.collision_mask = 1 + 2 + 16 # default layer, player, projectiles
	query.exclude.append(get_rid())
	var hit: Array[Dictionary] = space_state.intersect_shape(query)
	#print(hit)
	return not hit.is_empty()


func _begin_attack() -> void:
	look_at(current_targets[-1].position)
	rotation.x = 0
	state_machine.travel("attacking", true)
	change_state(State.ATTACKING)


func _attack(_delta) -> void:
	if state_timer >= attack_delay:
		do_attack()
	nav_agent.set_velocity(Vector3.ZERO)


func do_attack() -> void:
	if (not current_targets.is_empty()) and current_targets[-1] != null:
		look_at(current_targets[-1].global_position)
		rotation.x = 0
		spawner.look_at(current_targets[-1].global_position)
	var spawner_base_rotation = spawner.global_rotation
	for v in volley:
		spawner.global_rotation = spawner_base_rotation
		spawner.rotate_z(deg_to_rad(randf_range(-spread/2, spread/2)))
		spawner.rotate_y(deg_to_rad(randf_range(-spread/4, spread/4)))
		var instance = (nightmare_bullet if nightmare_bullet and Globals.s_nightmare else bullet).instantiate()
		spawner.add_child(instance)
		instance.reparent(get_tree().root)
		if instance is PhysicsBody3D:
			instance.add_collision_exception_with(self)
			add_collision_exception_with(instance)
		if instance is Hitscan:
			instance.query_origin = global_position
			instance.exceptions.append(self)
		instance.invoker = self
#	global_rotation = spawner_base_rotation
	spawner.global_rotation = spawner_base_rotation
	change_state(State.POST_ATTACKING)


func _post_attack(_delta) -> void:
	if state_timer >= attack_recovery_time:
		change_state(
				State.IDLE if current_targets.is_empty() or
				current_targets[-1] == null or
				current_targets[-1].find_child("Status").health <= 0 else State.PURSUING
		)
	if nav_agent != null:
		nav_agent.set_velocity(Vector3.ZERO)


func _flinch() -> void:
	if state_timer >= flinch_time:
		if randf() < flee_chance:
			change_state(State.FLEEING)
		else:
			change_state(State.PURSUING)
	if nav_agent != null:
		nav_agent.set_velocity(Vector3.ZERO)


func _flee(delta) -> void:
	_pursue(delta)


func _do_jump() -> void:
	state_machine.travel("jumping", true)
	if is_on_floor():
		jumping = true


func apply_knockback(amount: Vector3) -> void:
	if amount.y < 0:
		jump_vel = Vector3.ZERO
		grav_vel = Vector3.ZERO
		#jumping = false
	knockback_vel += amount * knockback_multiplier


func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor():
			jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(
			Vector3.ZERO, gravity * delta)
	if is_on_floor() and state_machine.get_current_node() == "jumping":
		state_machine.travel("moving", true)
	return jump_vel


func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(
			Vector3(0, velocity.y - gravity, 0), gravity * delta
	)
	return grav_vel


func _knockback(delta: float) -> Vector3:
	knockback_vel = knockback_vel.move_toward(Vector3.ZERO, knockback_drag * delta)
	return knockback_vel
	
	
func _to_fleeing() -> void:
	state_machine.travel("moving", true)


func get_tooltip() -> String:
	return Globals.parse_text(
			"tooltips", eat_tooltip
	) if edible and current_state == State.DEAD and state_timer > 1.0 else ""


func interact(body: Node3D) -> void:
	if not (current_state == State.DEAD and state_timer > 1.0 and edible and body is Player):
		return
	if (body as Player).status.heal(corpse_food_value):
		status.gibify()
		(body as Player).hud.flash(eat_flash_color)
		if eat_text != null and eat_text != "":
			(body as Player).hud.log_event(Globals.parse_text(
					"events", 
					eat_text
			) % corpse_food_value)


func _on_status_injured() -> void:
	if randf() < flinch_chance:
		change_state(State.FLINCHING)
	elif randf() < flee_chance * (1.0 - status.health / status.max_health):
		change_state(State.FLEEING)
	elif current_state == State.IDLE:
		change_state(State.PURSUING)


func _on_status_died() -> void:
	change_state(State.DEAD)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if nav_agent.avoidance_enabled:
		velocity += safe_velocity
		move_and_slide()
