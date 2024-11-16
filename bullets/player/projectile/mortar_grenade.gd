extends Bullet


@export var explode_timer: float = 0.0
@export var primed: bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if primed:
		explode_timer += delta
		if explode_timer >= randf():
			var e = (explosion).instantiate()
			add_child(e)
			e.reparent(get_tree().root)
			for child in e.get_children():
				if child is AreaDamage:
					child.invoker = invoker
			queue_free()
	else:
		super(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_fire_alt"): #and weapon_manager.current_category \
			#== required_weapon.x and weapon_manager.current_index[\
			#weapon_manager.current_category] == required_weapon.y:
		primed = true
		#Engine.time_scale *= 0.5
		
		
