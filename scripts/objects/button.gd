class_name InteractButton
extends Area3D


signal interacted

enum key {
	## The player cannot operate this button unless they have a red key.
	RED,
	## Ditto, but for the green key.
	GREEN,
	## Ditto, but for the blue key.
	BLUE,
	## No keys are required to operate this button.
	NONE = -1,
}

@export var targets: Array[AnimationTree] = []
## If false, the player can press this button again to revert it to its "off" state.
@export var one_way: bool = false
## Which, if any, key the player must have if they wish to operate this button.
@export var required_key: key = key.NONE
@export var current_state: bool = false
@export var alert: String = ""


func start() -> void:
#	targets.append_array(find_children("*", "AnimationTree"))
	for anim in targets:
		anim.get("parameters/playback").start("on" if current_state else "off")


func interact(body: Node3D) -> void:
	if required_key == key.NONE or body.find_child("Status").held_keys[required_key]:
		interacted.emit()
		current_state = true if one_way else not current_state
		#print(current_state)
		for anim in targets:
			anim.get("parameters/playback").travel("on" if current_state else "off")
		if alert != "":
			body.find_child("HUD").set_alert(alert)
	else:
		body.find_child("HUD").set_alert(
				"You need the %s key to open this door" % key.find_key(required_key)
		)
