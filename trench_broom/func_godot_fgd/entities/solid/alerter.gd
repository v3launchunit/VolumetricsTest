extends StaticBody3D

@export var properties: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func interacted(with: Node3D) -> void:
	if with is Player:
		with.hud.set_alert(Globals.parse_text("alerts", properties["alert"]))
