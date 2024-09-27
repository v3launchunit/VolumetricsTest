extends Node3D

@export var properties : Dictionary

@export_group("Save Data")
@export var open : bool = false

@onready var body := $Body as AnimatableBody3D
@onready var audio := $Stream as AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func interact(with: Node3D) -> void:
	set_open(not open)


func set_open(to: bool) -> void:
	if to == open:
		return
	audio.play()
