extends Marker3D

@export var func_godot_properties: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("targetname:%s" % func_godot_properties["targetname"], true)
	var tele := get_tree().get_first_node_in_group("targets:%s" % func_godot_properties["targetname"]) as Teleporter
	if tele == null:
		return
	tele.to.global_position = global_position
	tele.destination = tele.to.global_position
	tele.nav_link.set_global_end_position(tele.destination)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
