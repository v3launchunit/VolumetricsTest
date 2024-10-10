@tool

extends OmniLight3D


@export var func_godot_properties: Dictionary:
	set(to):
		if func_godot_properties != to:
			func_godot_properties = to
			update_properties()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_properties() -> void:
	if func_godot_properties["_color"] is Color:
		light_color = func_godot_properties["_color"]
	else:
		light_color = Color8(
				roundi(func_godot_properties.get("_color").x),
				roundi(func_godot_properties.get("_color").y),
				roundi(func_godot_properties.get("_color").z),
		)
	light_energy = func_godot_properties["energy"]
	light_bake_mode = BakeMode.BAKE_STATIC
	shadow_enabled = true
	
	omni_range = func_godot_properties["range"]
