class_name WeaponDualWield
extends WeaponDoubleBarrel


## The left-hand weapon's [AnimationTree].
@onready var anim_tree_l := find_children("AnimationTree")[0] as AnimationTree
## The [AnimationNodeStateMachinePlayback] associated with the left-hand weapon's [AnimationTree].
@onready var state_machine_l := anim_tree_l.get(
		"parameters/playback") as AnimationNodeStateMachinePlayback
## The right-hand weapon's [AnimationTree].
@onready var anim_tree_r := find_children("AnimationTree")[1] as AnimationTree
## The [AnimationNodeStateMachinePlayback] associated with the right-hand weapon's [AnimationTree].
@onready var state_machine_r := anim_tree_r.get(
		"parameters/playback") as AnimationNodeStateMachinePlayback


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = state_machine_l
	super()
	state_machine_r.start("deploy", true)


func _fire() -> void:
	state_machine = state_machine_r if from_alt_barrel else state_machine_l
	super()
