extends Node3D

signal interacted(with: Node3D)

@export var func_godot_properties: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if func_godot_properties["targetname"] != "":
		for member in get_tree().get_nodes_in_group("targets:%s" % func_godot_properties["targetname"]):
			if member.has_signal("interacted"):
				member.interacted.connect(on_triggered)
				#print("%s got targeted by %s" % [name, member.name])
		add_to_group("targetname:%s" % func_godot_properties["targetname"], true)
		
		for member in get_tree().get_nodes_in_group("targetname:%s" % func_godot_properties["target"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
				#print("%s targeted %s" % [name, member.name])
		add_to_group("targets:%s" %  func_godot_properties["target"], true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_triggered(by: Node3D) -> void:
	print("forwarder triggered")
	interacted.emit(by)
