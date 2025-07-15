@tool

extends Marker3D

@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		if not is_in_group("targetname:%s" % func_godot_properties["targetname"]):
			for group in get_groups():
				if not str(group).begins_with("_"):
					remove_from_group(group)
			add_to_group("targetname:%s" % func_godot_properties["targetname"], true)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not is_in_group("targetname:%s" % func_godot_properties["targetname"]):
		add_to_group("targetname:%s" % func_godot_properties["targetname"], true)
	var tele := get_tree().get_first_node_in_group("targets:%s" % func_godot_properties["targetname"]) as Teleporter
	if tele == null:
		return
	tele.to.global_position = global_position
	tele.destination = tele.to.global_position
	tele.nav_link.set_global_end_position(tele.destination)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
