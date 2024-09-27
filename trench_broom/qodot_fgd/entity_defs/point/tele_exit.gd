extends Marker3D

@export var properties: Dictionary

func _ready() -> void:
	add_to_group(properties["from"])
