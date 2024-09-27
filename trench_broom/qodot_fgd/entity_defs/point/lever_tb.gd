extends Area3D

signal interacted(with: Node3D)

@export var properties: Dictionary = {}
@export var on: bool = false
@export var cd_timer: float = 0.0

@onready var state_machine := $AnimationTree.get(
		"parameters/playback") as AnimationNodeStateMachinePlayback
@onready var sound_player := $AudioStreamPlayer3D as AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if properties["group"] != "none":
		for member in get_tree().get_nodes_in_group(properties["group"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group(properties["group"])
	state_machine.start("on" if on else "off")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cd_timer > 0.0:
		cd_timer -= delta


func interact(body: Node3D) -> void:
	if (on and properties["cooldown"] < 0.0) or cd_timer > 0.0:
		return
	interacted.emit(body)
	cd_timer = properties["cooldown"]
	on = not on
	if body is Player:
		body.hud.set_alert(Globals.parse_text(
				"alerts", 
				properties["pull_alert" if on else "unpull_alert"]
		))
	state_machine.travel("on" if on else "off")
	sound_player.play()
