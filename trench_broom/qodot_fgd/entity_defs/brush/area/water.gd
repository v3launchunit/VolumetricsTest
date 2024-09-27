extends Area3D

@export var properties: Dictionary

var center := Vector3.DOWN * 1000.0
var corner_nw := Vector3(-1000.0, 0.0, -1000.0)
var corner_se := Vector3(1000.0, 0.0, 1000.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#var mesh: MeshInstance3D = get_child(0) as MeshInstance3D
	#mesh.mesh = PlaneMesh.new()
	#for point: Vector3 in get_child(1).shape.points:
		#center.x += point.x
		#if point.y > center.y:
			#center.y = point.y
		#center.z += point.z
		#if point.x < corner_se.x:
			#corner_nw.x = point.x
		#if point.x > corner_se.x:
			#corner_se.x = point.x
		#if point.z < corner_se.z:
			#corner_nw.z = point.z
		#if point.z > corner_se.z:
			#corner_se.z = point.z
	#center.x /= get_child(1).shape.points.size()
	#center.z /= get_child(1).shape.points.size()
#
	#mesh.mesh.center_offset = center
	#mesh.mesh.size = Vector2(corner_nw.x - corner_se.x, corner_nw.z - corner_se.z)
	#mesh.mesh.subdivide_width = ceili(corner_nw.x - corner_se.x) - 1
	#mesh.mesh.subdivide_depth = ceili(corner_nw.z - corner_se.z) - 1
	#mesh.material_override = load("res://materials/terrain/trench_broom/water.tres")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
