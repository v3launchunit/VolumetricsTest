@tool
class_name PathNode
extends Marker3D

@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		for group in get_groups():
			if not str(group).begins_with("_"):
				remove_from_group(group)
		if func_godot_properties["targetname"] != "":
			add_to_group("targetname:%s" % func_godot_properties["targetname"], true)
		if func_godot_properties["target"] != "":
			add_to_group("targets:%s" %  func_godot_properties["target"], true)

var next: PathNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if func_godot_properties.get("targetname", "") != "" and not is_in_group("targetname:%s" % func_godot_properties["targetname"]):
		add_to_group("targetname:%s" % func_godot_properties["targetname"], true)
	if func_godot_properties.get("target", "") != "" and not is_in_group("targets:%s" % func_godot_properties["target"]):
		add_to_group("targets:%s" %  func_godot_properties["target"], true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if next == null and func_godot_properties.get("target", "") != "":
		next = get_tree().get_first_node_in_group("targetname:%s" %  func_godot_properties["target"]) as PathNode
