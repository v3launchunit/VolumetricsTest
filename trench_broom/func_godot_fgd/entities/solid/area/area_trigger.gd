extends Area3D

signal interacted(with: Node3D)

@export var func_godot_properties: Dictionary

@export_group("Save Data")
@export var trips: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)
	if func_godot_properties["group"] != "none":
		for member in get_tree().get_nodes_in_group(func_godot_properties["group"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group(func_godot_properties["group"])
	
	if func_godot_properties["target"] != "none":
		for member in get_tree().get_nodes_in_group("targetname:%s" % func_godot_properties["target"]):
			if member.has_method("on_triggered") and not interacted.is_connected(member.on_triggered):
				interacted.connect(member.on_triggered)
		add_to_group("targets:%s" %  func_godot_properties["target"], true)
		#add_to_group(func_godot_properties["target"])


func on_body_entered(body: Node3D) -> void:
	interacted.emit(body)
	#Console.print_line("AreaTrigger %s activated." % name)
	trips += 1
	if func_godot_properties["max_trips"] > 0 and trips >= func_godot_properties["max_trips"]:
		queue_free()
