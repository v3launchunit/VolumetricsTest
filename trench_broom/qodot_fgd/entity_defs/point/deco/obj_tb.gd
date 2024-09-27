extends Node3D

@export var properties: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#rotation.y = deg_to_rad(float(properties.get("angle", 0)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
