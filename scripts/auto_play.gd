extends AnimationPlayer


@export var animated_materials: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in animated_materials:
		if get_node(item) is MeshInstance3D:
			get_node(item).mesh = get_node(item).mesh.duplicate()
			get_node(item).mesh.material = get_node(item).mesh.material.duplicate()
		else:
			get_node(item).material = get_node(item).material.duplicate()
		get_node(item).global_position = get_parent().global_position
	play("anim")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
