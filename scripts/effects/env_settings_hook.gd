extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.settings_changed.connect(_on_globals_settings_changed)
	_on_globals_settings_changed()


func _on_globals_settings_changed() -> void:
	environment.glow_enabled = Globals.s_glow_enabled
	environment.volumetric_fog_enabled = Globals.s_volumetric_fog_enabled
	#environment.fog_enabled = not Globals.s_volumetric_fog_enabled
	environment.adjustment_enabled = Globals.s_palette_compress_enabled
