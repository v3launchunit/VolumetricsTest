@tool
extends Node3D

@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		configure()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func configure() -> void:
	var c : Color = func_godot_properties["window_light_color"]
	var light := find_child("SpotLight3D") as SpotLight3D
	if c.to_html(false) == "000000":
		light.hide()
	else:
		light.show()
		light.light_color = c
	var mesh := find_child("MeshInstance3D") as MeshInstance3D
	mesh.set_instance_shader_parameter("emission", c)
