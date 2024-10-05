extends StaticBody3D

@export var properties: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var status: Status = Status.new()
	status.max_health = properties.get("health")
	status.damage_sys = load(properties.get("damage_sys_path"))
	status.gibs = load(properties.get("gibs_path"))
	status.gib_threshold = 0.0
	#var center := Vector3.ZERO
	#for point: Vector3 in get_child(1).shape.points:
		#center += point
	#center /= get_child(1).shape.points.size()
	#status.gibs_offset = center
	add_child(status)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
