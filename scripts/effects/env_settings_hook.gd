extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.settings_changed.connect(_on_globals_settings_changed)
	_on_globals_settings_changed()


func _on_globals_settings_changed() -> void:
	environment.glow_enabled = Globals.s_glow_enabled
	environment.volumetric_fog_enabled = Globals.s_volumetric_fog_enabled
	#environment.fog_enabled = not Globals.s_volumetric_fog_enabled
	#environment.adjustment_enabled = Globals.s_palette_compress_enabled
	if (
		is_equal_approx(Globals.s_brightness, 1.0) 
		and is_equal_approx(Globals.s_contrast, 1.0) 
		and is_equal_approx(Globals.s_saturation, 1.0)
	):
		environment.adjustment_enabled = false
	else:
		environment.adjustment_enabled = true
		environment.adjustment_brightness = Globals.s_brightness
		environment.adjustment_contrast = Globals.s_contrast
		environment.adjustment_saturation = Globals.s_saturation
