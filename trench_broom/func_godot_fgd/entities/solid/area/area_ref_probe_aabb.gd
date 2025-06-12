@tool

extends ReflectionProbe


@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		blend_distance = func_godot_properties["blend_distance"]
		max_distance = func_godot_properties["max_distance"]
		if get_child(0) as MeshInstance3D:
			size = (get_child(0) as MeshInstance3D).mesh.get_aabb().abs().size
			get_child(0).queue_free()
		origin_offset = func_godot_properties["origin_offset"]
		#if func_godot_properties.get("origin") != null:
		box_projection = func_godot_properties["box_project"] != 0
		interior = func_godot_properties["interior"] != 0
		enable_shadows = func_godot_properties["reflect_shadows"] != 0
		
		if func_godot_properties.get("target", "") != "":
			add_to_group("targets:%s" %  func_godot_properties["target"], true)
		
		cull_mask = 0b0000_0000_0000_1001

var has_origin: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if func_godot_properties.get("target", "") != "" and not is_in_group("targets:%s" % func_godot_properties["target"]):
		add_to_group("targets:%s" %  func_godot_properties["target"], true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_origin and func_godot_properties.get("target", "") != "":
		#origin = get_tree().get_first_node_in_group("targetname:%s" %  func_godot_properties["target"]) as PathNode
		has_origin = true
		origin_offset = (get_tree().get_first_node_in_group("targetname:%s" % func_godot_properties["target"]) as PathNode).global_position - global_position
