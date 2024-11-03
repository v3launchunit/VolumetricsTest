@tool

extends MeshInstance3D


## Trenchbroom Properties
## Vector3 color
## Float energy
## Float range
@export var properties: Dictionary:
	set(to):
		if properties != to:
			properties = to
			update_properties()


func _ready() -> void:
	#if not Engine.is_editor_hint():
		#return
	#update_properties()
	pass


func update_properties() -> void:
	var color: Color
	if properties.has("_color"):
		color = properties["_color"] #Color8(
				#roundi(properties.get("_color").x),
				#roundi(properties.get("_color").y),
				#roundi(properties.get("_color").z),
		#)
	else:
		color = Color8(
				roundi(properties.get("color").x),
				roundi(properties.get("color").y),
				roundi(properties.get("color").z),
		)
	material_override = mesh.material.duplicate()

	set_instance_shader_parameter("albedo", color * properties.get("energy"))
	get_child(0).light_color = color
	get_child(0).light_energy = properties.get("energy")
	get_child(0).omni_range = properties.get("range")
	get_child(0).get_child(0).color = color
