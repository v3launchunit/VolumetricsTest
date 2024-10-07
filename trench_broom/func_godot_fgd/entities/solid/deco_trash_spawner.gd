@tool
extends StaticBody3D


const TRASH_LIST : Array[String] = [
		"res://objects/deco/trash/trash_bag_mesh.tscn",
		"res://objects/deco/trash/trash_bag_mesh.tscn",
		"res://objects/deco/trash/trash_pole.tscn",
		"res://objects/deco/trash/trash_brick.tscn",
		"res://objects/deco/trash/trash_brick.tscn",
		"res://objects/deco/trash/trash_brick.tscn",
		"res://scenes/objects/crate_metal.tscn",
		"res://objects/deco/trash/trash_chair.tscn",
]

@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		if is_inside_tree():
			spawn_trash_props()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#spawn_trash_props(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_trash_props(editor: bool = true) -> void:
	if editor and not Engine.is_editor_hint():
		collision_layer = 0b0000_0000_0000_0000_0000_0000_0000_0001
		return
	
	if func_godot_properties.get("seed", "") != "":
		seed(hash(func_godot_properties["seed"]))
	collision_layer = 0b0000_0000_0000_0000_0000_0010_0000_0000
	
	await ready
	var mesh := (get_child(0) as MeshInstance3D).mesh
	var shape := mesh.create_convex_shape(false)
	var points := shape.points
	var bounds := mesh.get_aabb().abs()
	var volume : float = bounds.get_volume()
	
	var pool := get_trash_list(func_godot_properties.get("trash_type", "trash"))
	
	var point_query := PhysicsPointQueryParameters3D.new()
	point_query.collide_with_bodies = true
	point_query.collide_with_areas = false
	point_query.collision_mask = 0b0000_0000_0000_0000_0000_0010_0000_0000
	
	for i in range(roundi(volume * func_godot_properties["prop_density"])):
		var pos := position + Vector3(
				randf_range(bounds.position.x, bounds.end.x), 
				randf_range(bounds.position.y, bounds.end.y), 
				randf_range(bounds.position.z, bounds.end.z),
		)
		var space_state := get_world_3d().direct_space_state
		point_query.position = pos
		var result := space_state.intersect_point(point_query, 1)
		
		if result == null or result.is_empty():
			continue
		
		var node := (load(pool.pick_random()) as PackedScene).instantiate() as Node3D
		add_child(node)
		node.set_owner(owner)
		node.global_position = pos
		node.rotation = Vector3(
				randf_range(-PI, PI), 
				randf_range(-PI, PI), 
				randf_range(-PI, PI),
		)
	
	collision_layer = 0b0000_0000_0000_0000_0000_0000_0000_0001
	if func_godot_properties.get("seed", "") != "":
		randomize()


func get_trash_list(type: int) -> Array[String]:
	var out : Array[String] = []
	var section : String = "trash_%s" % type
	
	var names := ConfigFile.new()
	if names.load("res://names.cfg") or not names.has_section(section):
		#print(TRASH_LIST)
		return TRASH_LIST
	
	for key in names.get_section_keys(section):
		if key.begins_with("include_"):
			get_trash_list(names.get_value(section, key))
			continue
		out.append(names.get_value(section, key))
	#print(out)
	return out
