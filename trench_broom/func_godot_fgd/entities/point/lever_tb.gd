extends Area3D

signal interacted(with: Node3D)

@export var func_godot_properties: Dictionary = {}
@export var on: bool = false
@export var cd_timer: float = 0.0

@onready var state_machine := $AnimationTree.get(
		"parameters/playback") as AnimationNodeStateMachinePlayback
@onready var sound_player := $AudioStreamPlayer3D as AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if func_godot_properties["group"] != "none":
		for member in get_tree().get_nodes_in_group(func_godot_properties["group"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
				#print("%s targeted %s" % [name, member.name])
		add_to_group(func_godot_properties["group"])
	if func_godot_properties["target"] != "":
		for member in get_tree().get_nodes_in_group("targetname:%s" % func_godot_properties["target"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
				#print("%s targeted %s" % [name, member.name])
		add_to_group("targets:%s" % func_godot_properties["target"])
	state_machine.start("on" if on else "off")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cd_timer > 0.0:
		cd_timer -= delta


func interact(body: Node3D) -> void:
	if (on and func_godot_properties["cooldown"] < 0.0) or cd_timer > 0.0:
		return
	interacted.emit(body)
	cd_timer = func_godot_properties["cooldown"]
	on = not on
	if body is Player and func_godot_properties["pull_alert" if on else "unpull_alert"] != "":
		body.hud.set_alert(Globals.parse_text(
				"alerts", 
				func_godot_properties["pull_alert" if on else "unpull_alert"]
		))
	state_machine.travel("on" if on else "off")
	sound_player.play()
