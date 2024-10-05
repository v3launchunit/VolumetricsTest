@tool

extends Node3D


@export var func_godot_properties: Dictionary:
	set(to):
		func_godot_properties = to
		match func_godot_properties["mount_type"]:
			0:
				$Base.mesh = floor_base
			1:
				$Base.mesh = wall_base
				await ready
				var origin_vec: Vector3 = Vector3.ZERO
				var origin_comps: PackedFloat64Array = func_godot_properties['origin'].split_floats(' ')
				if origin_comps.size() > 2:
					origin_vec = Vector3(origin_comps[1], origin_comps[2], origin_comps[0])
				else:
					push_error("Invalid vector format for \'origin\' in " + name)
				position = (origin_vec / 16) + (global_basis.z * -0.35)
@export var floor_base: Mesh
@export var wall_base: Mesh


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
