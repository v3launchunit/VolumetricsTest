@tool
extends StaticBody3D


@export var func_godot_properties : Dictionary


func _func_godot_build_complete() -> void:
	($MeshInstance3D.material_override as ShaderMaterial).set_shader_parameter("albedo_col", func_godot_properties["_color"])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
