class_name AStarFlood3DGizmo
extends EditorNode3DGizmoPlugin


func get_name() -> String:
	return _get_gizmo_name()


func _get_gizmo_name() -> String:
	return "AStarFlood3DGizmo"


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is AStarFlood3D


func _init() -> void:
	create_material("main", Color(1.0, 0.5, 0.0))


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var node := gizmo.get_node_3d() as AStarFlood3D
	var lines := PackedVector3Array()

	var pos: Vector3 = node.region.position
	var size: Vector3 = node.region.size
	#lines.append(pos)
	#lines.append(pos + Vector3(size.x, 0.0, 0.0))
	#lines.append(pos)
	#lines.append(pos + Vector3(0.0, size.y, 0.0))
	#lines.append(pos)
	#lines.append(pos + Vector3(0.0, 0.0, size.z))
#
	#lines.append(pos + Vector3(size.x, 0.0, 0.0))
	#lines.append(pos + Vector3(size.x, size.y, 0.0))
	#lines.append(pos + Vector3(size.x, 0.0, 0.0))
	#lines.append(pos + Vector3(size.x, 0.0, size.z))

	#gizmo.add_lines(lines, get_material("main", gizmo))
	var mesh := BoxMesh.new()
	mesh.size = size

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.5, 0.0, 0.5)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	gizmo.add_mesh(mesh, mat, Transform3D(Basis.IDENTITY, pos + size*0.5))
