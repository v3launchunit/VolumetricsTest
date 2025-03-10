extends Node3D

@export_storage var anim_progress : float = 0.0

@onready var player := find_child("AnimationPlayer") as AnimationPlayer


func _ready() -> void:
	if anim_progress > 0.0:
		player.seek(anim_progress, true)


func _save() -> void:
	anim_progress = player.current_animation_position
