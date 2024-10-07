extends Node3D

@export var properties: Dictionary

var initiated: bool = false


func _process(delta: float) -> void:
	if initiated:
		queue_free()
		return
	var effect := (load(Globals.parse_names("effects", properties["effect"])) as PackedScene)
	var e: Node = effect.instantiate()
	add_child(e)
	e.reparent(get_parent_node_3d())
	initiated = true
