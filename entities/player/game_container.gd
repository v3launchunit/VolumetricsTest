extends SubViewportContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.settings_changed.connect(_on_globals_settings_changed)
	_on_globals_settings_changed()


func _on_globals_settings_changed() -> void:
	stretch_shrink = Globals.s_stretch_scale / floori(Globals.s_ui_scale)
