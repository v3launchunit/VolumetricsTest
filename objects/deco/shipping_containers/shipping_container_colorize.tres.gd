@tool
extends StaticBody3D


@export var func_godot_properties : Dictionary
@export var color := Color.BLACK


func _func_godot_build_complete() -> void:
	if color.is_equal_approx(Color.BLACK):
		color = func_godot_properties["_color"] as Color
		if color.is_equal_approx(Color.BLACK):
			color = Color.from_hsv(randf(), sqrt(randf()), 1.0)
	($Container.material_override as ShaderMaterial).set_shader_parameter("albedo_col", color)
	($Doors.material_override as ShaderMaterial).set_shader_parameter("albedo_col", color)
	if func_godot_properties.get("closed", false):
		$CollisionShape3D.shape = BoxShape3D.new()
		$CollisionShape3D.shape.size = Vector3(2.5, 2.6, 6.0)
		$Doors.show()
	
	#$Containers.owner = owner
	#$CollisionShape3D.owner = owner
	#$Doors.owner = owner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not func_godot_properties.is_empty():
		_func_godot_build_complete()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
