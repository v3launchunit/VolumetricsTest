class_name Pickup 
extends RigidBody3D


@export var flash_color: Color = Color.GREEN
@export var pickup_sound: AudioStream
@export var pickup_text: String

@onready var area: Area3D = find_child("Area3D")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(interact)
	find_child("AnimationPlayer").play("anim")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func interact(_body: Node3D) -> void:
	pass


func picked_up(body: Node) -> void:
	if body is not Player:
		return
	
	var hud := (body as Player).hud
	if pickup_sound != null:
		hud.flash_with_sound(flash_color, pickup_sound)
	else:
		hud.flash(flash_color)

	if pickup_text != null and pickup_text != "":
		hud.log_event(pickup_text)

	queue_free()
