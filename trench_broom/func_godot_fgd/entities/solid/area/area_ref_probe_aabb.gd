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
		box_projection = func_godot_properties["box_project"] != 0
		interior = func_godot_properties["interior"] != 0
		enable_shadows = func_godot_properties["reflect_shadows"] != 0
		
		cull_mask = 0b0000_0000_0000_1001


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
