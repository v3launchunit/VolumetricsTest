@tool
extends StaticBody3D


@export var func_godot_properties : Dictionary


func _func_godot_build_complete() -> void:
	var c := func_godot_properties["_color"] as Color
	if c.is_equal_approx(Color.BLACK):
		c = Color.from_hsv(randf(), sqrt(randf()), 1.0)
	($Container.material_override as ShaderMaterial).set_shader_parameter("albedo_col", c)
	($Doors.material_override as ShaderMaterial).set_shader_parameter("albedo_col", c)
	if func_godot_properties["closed"]:
		$CollisionShape3D.shape = BoxShape3D.new()
		$CollisionShape3D.shape.size = Vector3(2.5, 2.6, 6.0)
		$Doors.show()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
