class_name Lifetime extends Timer

#@export var wait_time: float = 10.0
@export var decay_explosion: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	timeout.connect(_on_timeout)
	start()


func _on_timeout():
	if decay_explosion != null:
		var e = decay_explosion.instantiate()
		get_parent().add_child(e)
		e.reparent(get_tree().root)

	get_parent().queue_free()
