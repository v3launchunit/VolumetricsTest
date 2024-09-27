extends EnemyBase

@export var min_distance: float = 3.0

@onready var min_dist_squared: float = min_distance * min_distance


#func should_jump() -> bool:
	#return (
			#check_target_validity()
			#and current_targets[-1].global_position.distance_squared_to(
					#global_position
			#) <= min_dist_squared
	#) #or randf() < 0.01


func _do_jump() -> void:
	if is_on_floor():
		jumping = true
		#jump_vel.z = -speed * jump_height
		#if current_targets[-1].global_position.distance_squared_to(
				#global_position) <= min_dist_squared:
