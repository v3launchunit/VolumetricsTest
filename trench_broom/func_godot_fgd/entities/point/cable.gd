@tool
class_name Cable
extends MeshInstance3D

@export var rebuild : bool:
	set(to):
		_func_godot_build_complete()
@export var func_godot_properties : Dictionary
@export var cable_end_l : Node3D
@export var cable_end_r : Node3D

#@onready var mesh := $MeshInstance3D as MeshInstance3D

func _func_godot_build_complete() -> void:
	if cable_end_l == null and func_godot_properties.get("target", "") != "":
		cable_end_l = get_tree().get_first_node_in_group(
				"targetname:%s" % func_godot_properties["target"]
		) as Node3D
	if cable_end_r == null and func_godot_properties.get("killtarget", "") != "":
		cable_end_r = get_tree().get_first_node_in_group(
				"targetname:%s" % func_godot_properties["killtarget"]
		) as Node3D
	
	if cable_end_l == null or cable_end_r == null:
		printerr(cable_end_l == null)
		printerr(cable_end_r == null)
		return
	
	var left_end_pos : Vector3 = cable_end_l.global_position - global_position
	var right_end_pos : Vector3 = cable_end_r.global_position - global_position
	
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var colors := PackedColorArray()
	
	#verts.push_back(left_end_pos + func_godot_properties["radius"] * cable_end_l.global_basis.y)
	#colors.push_back(Color(1.0, 0.0, 0.0))
	#verts.push_back(left_end_pos + func_godot_properties["radius"] * cable_end_l.global_basis.x)
	#colors.push_back(Color(1.0, 0.0, 0.0))
	#verts.push_back(left_end_pos - func_godot_properties["radius"] * cable_end_l.global_basis.y)
	#colors.push_back(Color(1.0, 0.0, 0.0))
	#verts.push_back(left_end_pos - func_godot_properties["radius"] * cable_end_l.global_basis.x)
	#colors.push_back(Color(1.0, 0.0, 0.0))
	#
	#verts.push_back(func_godot_properties["radius"] * Vector3.UP.cross(left_end_pos * Vector3(1.0, 0.0, 1.0)).normalized())
	#colors.push_back(Color(1.0, 1.0, 0.0))
	#verts.push_back(Vector3(0.0, func_godot_properties["radius"], 0.0))
	#colors.push_back(Color(0.0, 1.0, 0.0))
	#verts.push_back(func_godot_properties["radius"] * Vector3.DOWN.cross(left_end_pos * Vector3(1.0, 0.0, 1.0)).normalized())
	#colors.push_back(Color(0.0, 1.0, 1.0))
	#verts.push_back(Vector3(0.0, -func_godot_properties["radius"], 0.0))
	#colors.push_back(Color(0.0, 0.0, 1.0))
	#
	#verts.push_back(left_end_pos)
	#colors.push_back(Color(1.0, 1.0, 0.0))
	#verts.push_back(Vector3.ZERO)
	#colors.push_back(Color(1.0, 0.0, 1.0))
	#verts.push_back(right_end_pos)
	#colors.push_back(Color(0.0, 0.0, 1.0))
	
	for i in range(func_godot_properties["segments"] + 1):
		var w = i / float(func_godot_properties["segments"])
		
		if func_godot_properties["radius"] <= 0.0:
			verts.push_back(sample_curve(w))
			#colors.push_back(Color.RED.lerp(Color.GREEN, i / float(func_godot_properties["segments"])))
		else:
			verts.push_back(sample_curve(w) + func_godot_properties["radius"] * cable_end_l.global_basis.y.lerp(cable_end_r.global_basis.y, w)) #Vector3.UP)
			verts.push_back(sample_curve(w) + func_godot_properties["radius"] * cable_end_l.global_basis.x.lerp(-cable_end_r.global_basis.x, w)) #Vector3.RIGHT)
			verts.push_back(sample_curve(w) + func_godot_properties["radius"] * (-cable_end_l.global_basis.y).lerp(-cable_end_r.global_basis.y, w)) #Vector3.DOWN)
			verts.push_back(sample_curve(w) + func_godot_properties["radius"] * (-cable_end_l.global_basis.x).lerp(cable_end_r.global_basis.x, w)) #Vector3.LEFT)
			
			norms.push_back(cable_end_l.global_basis.y.lerp(cable_end_r.global_basis.y, w).normalized())
			norms.push_back(cable_end_l.global_basis.x.lerp(-cable_end_r.global_basis.x, w).normalized())
			norms.push_back((-cable_end_l.global_basis.y).lerp(-cable_end_r.global_basis.y, w).normalized())
			norms.push_back((-cable_end_l.global_basis.x).lerp(cable_end_r.global_basis.x, w).normalized())
			
			colors.push_back(Color.RED.lerp(Color.RED, i / float(func_godot_properties["segments"])))
			colors.push_back(Color.YELLOW.lerp(Color.YELLOW, i / float(func_godot_properties["segments"])))
			colors.push_back(Color.GREEN.lerp(Color.GREEN, i / float(func_godot_properties["segments"])))
			colors.push_back(Color.BLUE.lerp(Color.BLUE, i / float(func_godot_properties["segments"])))
	
	var arr_mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	#arrays[Mesh.ARRAY_COLOR] = colors
	if func_godot_properties["radius"] <= 0.0:
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, arrays)
	else:
		var indices := PackedInt32Array()
		for i in range(func_godot_properties["segments"]):
			indices.push_back(i * 4)
			indices.push_back(i * 4 + 4)
			indices.push_back(i * 4 + 1)
			
			indices.push_back(i * 4 + 1)
			indices.push_back(i * 4 + 5)
			indices.push_back(i * 4 + 2)
			
			indices.push_back(i * 4 + 2)
			indices.push_back(i * 4 + 6)
			indices.push_back(i * 4 + 3)
			
			indices.push_back(i * 4 + 3)
			indices.push_back(i * 4 + 7)
			indices.push_back(i * 4 + 4)
			
			indices.push_back(i * 4)
			indices.push_back(i * 4 + 3)
			indices.push_back(i * 4 + 4)
			
			indices.push_back(i * 4 + 1)
			indices.push_back(i * 4 + 4)
			indices.push_back(i * 4 + 5)
			
			indices.push_back(i * 4 + 2)
			indices.push_back(i * 4 + 5)
			indices.push_back(i * 4 + 6)
			
			indices.push_back(i * 4 + 3)
			indices.push_back(i * 4 + 6)
			indices.push_back(i * 4 + 7)
		arrays[Mesh.ARRAY_NORMAL] = norms
		arrays[Mesh.ARRAY_INDEX] = indices
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, arrays)
	
	global_rotation = Vector3(0.0, 0.0, 0.0)
	mesh = arr_mesh


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func sample_curve(weight: float) -> Vector3:
	var left_end_pos : Vector3 = cable_end_l.global_position - global_position
	var right_end_pos : Vector3 = cable_end_r.global_position - global_position
	
	var x : float = lerp(left_end_pos.x, right_end_pos.x, weight)
	var z : float = lerp(left_end_pos.z, right_end_pos.z, weight)
	
	var A_1 = -(left_end_pos.x * left_end_pos.x)
	var B_1 = -left_end_pos.x
	var C_1 = -left_end_pos.y
	var A_2 = -(right_end_pos.x * right_end_pos.x)
	var B_2 = -right_end_pos.x
	var C_2 = -right_end_pos.y
	var B_mul = -(B_2 / B_1)
	var A_3 = B_mul * A_1 + A_2
	var C_3 = B_mul * C_1 + C_2
	var a = C_3 / A_3
	var b = (C_1 - A_1 * a) / B_1
	var c = left_end_pos.y - a * left_end_pos.x * left_end_pos.x - b * left_end_pos.x
	
	var y : float = a * x * x + b * x + c
	
	return Vector3(x, y, z)
