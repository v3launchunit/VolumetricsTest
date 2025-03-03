extends StaticBody3D

@export var func_godot_properties: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func interact(with: Node3D) -> void:
	if with is Player:
		with.hud.set_alert(Globals.parse_text("alerts", func_godot_properties["alert"]))
