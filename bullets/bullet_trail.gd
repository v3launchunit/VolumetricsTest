extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().has_signal("detonated"):
		get_parent().detonated.connect(_on_detonated)
	elif not get_parent().body_entered.is_connected(_on_bullet_body_entered):
		get_parent().body_entered.connect(_on_bullet_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_detonated():
	_on_bullet_body_entered(null)


func _on_bullet_body_entered(_body):
	reparent(get_tree().root)
	emitting = false
	await get_tree().create_timer(lifetime).timeout
	queue_free()
