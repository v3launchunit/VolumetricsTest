@tool
class_name Floodlight
extends RigidBody3D


@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		for group in get_groups():
			if not str(group).begins_with("_"):
				remove_from_group(group)
		if func_godot_properties.get("target", "") != "":
			add_to_group("targets:%s" %  func_godot_properties["target"], true)
		if func_godot_properties.get("killtarget", "") != "":
			add_to_group("targets:%s" %  func_godot_properties["killtarget"], true)
		
		#await (ready)
		#await (get_tree().process_frame)


func _func_godot_build_complete() -> void:
	if func_godot_properties.get("target", "") != "":
		($floodlight/Stand/Neck_L/Lamp_L as Node3D).look_at(
				(
						get_tree().get_first_node_in_group(
								"targetname:%s" % func_godot_properties["target"]
						) as Node3D
				).global_position,
				Vector3.UP,
				true
		)
	if func_godot_properties.get("killtarget", "") != "":
		($floodlight/Stand/Neck_R/Lamp_R as Node3D).look_at(
				(
						get_tree().get_first_node_in_group(
								"targetname:%s" % func_godot_properties["killtarget"]
						) as Node3D
				).global_position,
				Vector3.UP,
				true
		)


func _ready() -> void:
	pass
