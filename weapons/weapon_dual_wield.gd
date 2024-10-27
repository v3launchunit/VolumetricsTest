class_name WeaponDualWield
extends WeaponDoubleBarrel


## This weapon's [AnimationTree].
@onready var anim_tree_r := find_child("AnimationTree2") as AnimationTree
## The [AnimationNodeStateMachinePlayback] associated with this weapon's [AnimationTree].
@onready var state_machine_r := anim_tree_r.get(
		"parameters/playback") as AnimationNodeStateMachinePlayback


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
