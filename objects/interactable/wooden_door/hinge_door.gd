extends AnimatableBody3D


@export_storage var open: bool = false


signal interacted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, 90 if open else 0, delta)


func interact(body: Node3D) -> void:
	interacted.emit()
	open = not open


func get_tooltip() -> String:
	return (
			"" # inoperable and/or moving
			if rotation.y > 1.0 and rotation.y < 89.0
			else Globals.parse_text("tooltips", "open") # opened
			if open
			else Globals.parse_text("tooltips", "close") # closed but not locked
	)
