extends Hitscan

@onready var lightning_mesh: CylinderMesh = (
		find_child("Lightning") as MeshInstance3D).mesh as CylinderMesh


func _process(delta: float) -> void:
	super(delta)
	lightning_mesh.rings = floori(mesh.scale.z) + 1
