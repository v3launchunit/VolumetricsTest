class_name LodgedHarpoon
extends Node3D


@export var reel_strength: float = 50.0

@export_group("Save Data")
@export var invoker: Node3D
@export var victim: Node3D
@export var primed: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_fire_alt"):
		primed = true
