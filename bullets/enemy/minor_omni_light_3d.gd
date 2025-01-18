class_name MinorOmniLight3D
extends OmniLight3D

@export var no_shadows: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.settings_changed.connect(_on_globals_settings_changed)
	_on_globals_settings_changed()
	distance_fade_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_globals_settings_changed() -> void:
	visible = Globals.s_minor_lights
	shadow_enabled = Globals.s_minor_shadows and not no_shadows
	omni_shadow_mode = Globals.s_minor_shadows_mode
