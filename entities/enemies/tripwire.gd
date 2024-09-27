class_name AreaTripwire extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_mask = 2
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
#	print("wire tripped")
	if body is Player:
		for child in get_children():
			if child.has_method("detect_target"):
				child.detect_target(body)
				child.reparent(get_parent_node_3d())
