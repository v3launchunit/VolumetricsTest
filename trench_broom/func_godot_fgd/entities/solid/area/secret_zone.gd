class_name AreaSecret
extends Area3D

signal interacted(with: Node3D)

@export var properties: Dictionary

var alert_sound := preload("res://audio/streams/effects/doom_secret.ogg") as AudioStream

@onready var level := get_tree().current_scene as Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if level and not level.loaded_from_savegame:
		level.secrets += 1
	
	if properties["group"] != "none":
		for member in get_tree().get_nodes_in_group(properties["group"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group(properties["group"])
	if properties["target"] != "none":
		for member in get_tree().get_nodes_in_group(properties["target"]):
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body: Node3D) -> void:
	if level and body is Player:
		level.found_secrets += 1
		var hud := (body as Player).hud
		
		hud.set_alert(Globals.parse_text("alerts", "secret") % [
				max(ceili(log(level.secrets)) / log(10), 1), 
				level.found_secrets, 
				level.secrets,
		], alert_sound)
	
		if properties["group"] != "none":
			interacted.emit(body)
		queue_free()
