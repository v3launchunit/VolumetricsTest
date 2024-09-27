extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		child.reparent(get_tree().root.get_child(Globals.C_AUTOLOAD_COUNT))
