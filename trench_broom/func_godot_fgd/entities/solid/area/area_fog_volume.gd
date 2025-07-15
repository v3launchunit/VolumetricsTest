@tool

extends FogVolume


@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		shape = func_godot_properties["shape"]
		if get_child(0) as MeshInstance3D:
			size = (get_child(0) as MeshInstance3D).mesh.get_aabb().abs().size
			get_child(0).queue_free()
		rotation_degrees = func_godot_properties["angles"]
		#if func_godot_properties.get("origin") != null:
		material = FogMaterial.new()
		material.albedo = func_godot_properties["_color"]
		material.emission = func_godot_properties["_glow"]
		material.density = func_godot_properties["density"]
		material.edge_fade = func_godot_properties["edge_fade"]
		material.height_falloff = func_godot_properties["height_falloff"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
