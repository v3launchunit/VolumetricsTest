extends Node3D

signal interacted(with: Node3D)

@export var func_godot_properties: Dictionary

@export_storage var count: int = 0

var countdown_alert: String
var completion_alert: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if func_godot_properties["in_group"] != "none":
		for member in get_tree().get_nodes_in_group(func_godot_properties["in_group"]):
			if member.has_signal("interacted"):
				member.interacted.connect(on_triggered)
		add_to_group(func_godot_properties["in_group"], true)
		
		for member in get_tree().get_nodes_in_group(func_godot_properties["out_group"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group(func_godot_properties["out_group"], true)
	
	if func_godot_properties["targetname"] != "":
		# find nodes targeting this one
		for member in get_tree().get_nodes_in_group("targets:%s" % func_godot_properties["targetname"]):
			if member.has_signal("interacted"):
				member.interacted.connect(on_triggered)
		add_to_group("targetname:%s" % func_godot_properties["targetname"], true)
		
		# find nodes this one targets
		for member in get_tree().get_nodes_in_group("targetname:%s" % func_godot_properties["target"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group("targets:%s" % func_godot_properties["target"], true)

	count = func_godot_properties["in_count"]
		#add_to_group(func_godot_properties["target"], true)
	#print(func_godot_properties)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#print(func_godot_properties)
	#print(func_godot_properties["countdown_alert"])



func on_triggered(by: Node3D) -> void:
	count -= 1
	print(func_godot_properties)
	print(func_godot_properties["countdown_alert"])
	if count <= 0:
		interacted.emit(by)
		if by is Player:
			by.hud.set_alert(Globals.parse_text(
					"alerts", 
					func_godot_properties.get("completion_alert", "sequence.complete")
			))
		await get_tree().process_frame
		queue_free()
	elif by is Player:
		by.hud.set_alert(Globals.parse_text(
				"alerts", 
				func_godot_properties.get("countdown_alert", "sequence.countdown")
		) % count)
