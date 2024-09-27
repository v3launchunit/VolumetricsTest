extends Area3D

signal interacted(with: Node3D)

@export var properties: Dictionary

@export_group("Save Data")
@export var trips: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)
	if properties["group"] != "none":
		for member in get_tree().get_nodes_in_group(properties["group"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group(properties["group"])


func on_body_entered(body: Node3D) -> void:
	interacted.emit(body)
	trips += 1
	if properties["max_trips"] > 0 and trips >= properties["max_trips"]:
		queue_free()
