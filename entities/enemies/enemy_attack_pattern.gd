class_name EnemyAttackPattern
extends EnemyBase

enum PatternSelectionMode {
	RANDOM,
	SEQUENTIAL,
}

#@export_group("Combat")
@export var pattern_selection_mode: PatternSelectionMode = PatternSelectionMode.RANDOM
@export var patterns: Array[AttackPattern]

var current_pattern: int = 0
var current_burst: int = 0

@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer") as AnimationPlayer


func _pursue(delta) -> void:
	# weird hacky randomization algorithm
	# Every frame the enemy is moving, it has a random chance to ready the next
	# attack in the sequence, based on the weight of the current attack pattern
	if (
			pattern_selection_mode == PatternSelectionMode.RANDOM
			and randf_range(0.0, 101.0) >= patterns[current_pattern].weight
	):
		current_pattern += 1
		if current_pattern >= patterns.size():
			current_pattern = 0

	super(delta)


func _begin_attack() -> void:
	if pattern_selection_mode == PatternSelectionMode.SEQUENTIAL:
		current_pattern += 1
		if current_pattern >= patterns.size():
			current_pattern = 0

	look_at(current_targets[-1].position)
	rotation.x = 0
	print(patterns[current_pattern].animation)
	state_machine.travel(patterns[current_pattern].animation, true)
	change_state(State.ATTACKING)


func _attack(_delta) -> void:
	if (
			state_timer >= patterns[current_pattern].delay
			+ current_burst * patterns[current_pattern].burst_delay
	):
		if patterns[current_pattern].cancelable and not can_see_target():
			change_state(State.POST_ATTACKING)
			anim_player.seek(
					patterns[current_pattern].delay
					+ patterns[current_pattern].burst
					* patterns[current_pattern].burst_delay
			)
		else:
			do_attack()
	if nav_agent != null:
		nav_agent.set_velocity(Vector3.ZERO)


func do_attack() -> void:
	look_at(current_targets[-1].position)
	rotation.x = 0
	var current_bullet: PackedScene = (
			patterns[current_pattern].nightmare_bullet
			if patterns[current_pattern].nightmare_bullet 
					and Globals.s_nightmare
			else patterns[current_pattern].bullet
	)
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

	if (not current_targets.is_empty()) and current_targets[-1] != null:
		current_spawner.look_at(current_targets[-1].global_position)
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
