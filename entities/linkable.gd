extends Node


@export var _targetname: StringName = ""
@export var _target: StringName = ""
@export var _killtarget: StringName = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _set_links(targetname: StringName, target: StringName, killtarget: StringName) -> void:
	pass


func _set_targetname(targetname: StringName) -> void:
	pass
