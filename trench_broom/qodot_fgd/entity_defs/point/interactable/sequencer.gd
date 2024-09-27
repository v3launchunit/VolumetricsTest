extends Node3D

signal interacted(with: Node3D)

@export var properties: Dictionary

@export var count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if properties["in_group"] != "none":
		for member in get_tree().get_nodes_in_group(properties["in_group"]):
			if member.has_signal("interacted"):
				member.interacted.connect(countdown)
		add_to_group(properties["in_group"], true)
		
		for member in get_tree().get_nodes_in_group(properties["out_group"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group(properties["out_group"], true)
		
		count = properties["in_count"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func countdown(by: Node3D) -> void:
	count -= 1
	if by is Player:
		by.hud.set_alert(Globals.parse_text("alerts", properties["countdown_alert"]))
	if count <= 0:
		interacted.emit(by)
		if by is Player:
			by.hud.set_alert(Globals.parse_text("alerts", properties["completion_alert"]))
		await get_tree().process_frame
		queue_free()
