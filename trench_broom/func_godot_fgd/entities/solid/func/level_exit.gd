extends StaticBody3D


@export var func_godot_properties: Dictionary

@onready var level := get_tree().current_scene as Level


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func get_tooltip() -> String:
	return Globals.parse_text("tooltips", func_godot_properties["tooltip"])


func interact(with: Node3D) -> void:
	var time := level.time
	var foes := level.foes
	var kills := level.kills
	var secrets := level.secrets
	var found_secrets := level.found_secrets
	
	Globals.clear_level(level.level_key)
	Globals.reveal_level(func_godot_properties["next"])
	Intermission.run_intermission(with, time, foes, kills, secrets, found_secrets, func_godot_properties["next"])
