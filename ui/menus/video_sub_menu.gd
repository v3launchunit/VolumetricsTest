extends VBoxContainer

@onready var res_x: LineEdit = find_child("ResolutionX")
@onready var res_y: LineEdit = find_child("ResolutionY")

@onready var scale_slider: HSlider = find_child("ScaleSlider")
@onready var scale_label: Label = find_child("ScaleLabel")

@onready var ui_scale_slider: HSlider = find_child("UIScaleSlider")
@onready var ui_scale_label: Label = find_child("UIScaleLabel")

@onready var crosshair_size_slider: HSlider = find_child("CrosshairSizeSlider")
@onready var crosshair_size_label: Label = find_child("CrosshairSizeLabel")

@onready var fov_slider: HSlider = find_child("FovSlider")
@onready var fov_label: Label = find_child("FovLabel")

@onready var snap_slider: HSlider = find_child("SnapSlider")
@onready var snap_label: Label = find_child("SnapLabel")

@onready var flares_check: CheckButton = find_child("FlaresCheck")
@onready var bloom_check: CheckButton = find_child("BloomCheck")
@onready var cbloom_check: CheckButton = find_child("CBloomCheck")
@onready var volumetric_fog_check: CheckButton = find_child("VolumetricFogCheck")
@onready var affine_warp_check: CheckButton = find_child("AffineWarpCheck")

@onready var palette_check: CheckButton = find_child("PaletteCheck")
@onready var palette_dropdown: OptionButton = find_child("PaletteSelect")
@onready var depth_slider: HSlider = find_child("DepthSlider")
@onready var depth_label: Label = find_child("DepthLabel")

#@onready var _press_sound: AudioStreamPlayer = get_node("/root/GameMenu/ButtonPress")


func _ready() -> void:
	#scale_slider.set_value_no_signal(Globals.s_stretch_scale)
	scale_slider.value = Globals.s_stretch_scale
	scale_label.text = "%sx" % Globals.s_stretch_scale
	#ui_scale_slider.set_value_no_signal(Globals.s_ui_scale)
	ui_scale_slider.value = Globals.s_ui_scale
	ui_scale_label.text = "%sx" % Globals.s_ui_scale
	#fov_slider.set_value_no_signal(Globals.s_fov_desired)
	fov_slider.value = Globals.s_fov_desired
	fov_label.text = "%s" % Globals.s_fov_desired
	#snap_slider.set_value_no_signal(Globals.s_vertex_snap)
	snap_slider.value = Globals.s_vertex_snap
	match floori(Globals.s_vertex_snap):
		0:
			snap_label.text = "Off"
		1:
			snap_label.text = "Tasteful"
		2:
			snap_label.text = "Mild"
		3:
			snap_label.text = "Moderate"
		4:
			snap_label.text = "Intense"
		5:
			snap_label.text = "Extreme"
	#flares_check.set_pressed_no_signal(Globals.s_flares_enabled)
	flares_check.button_pressed = Globals.s_flares_enabled
	#bloom_check.set_pressed_no_signal(Globals.s_glow_enabled)
	bloom_check.button_pressed = Globals.s_glow_enabled
	#cbloom_check.set_pressed_no_signal(Globals.s_cross_glow_enabled)
	cbloom_check.button_pressed = Globals.s_cross_glow_enabled
	volumetric_fog_check.button_pressed = Globals.s_volumetric_fog_enabled
	affine_warp_check.button_pressed = Globals.s_affine_warp


func _on_resolution_apply_button_pressed() -> void:
	#_press_sound.play()
	if not res_x.text.is_valid_int():
		res_x.text = ProjectSettings.get_setting("display/window/size/viewport_width")
		return

	if not res_y.text.is_valid_int():
		res_y.text = ProjectSettings.get_setting("display/window/size/viewport_height")
		return

	ProjectSettings.set_setting("display/window/size/viewport_width", res_x)
	ProjectSettings.set_setting("display/window/size/viewport_height", res_y)


func _on_scale_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_stretch_scale = floori(value)
	scale_label.text = "%sx" % value


#func _on_scale_slider_drag_ended(value_changed: bool) -> void:
	#pass


func _on_ui_scale_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	ProjectSettings.set_setting("display/window/stretch/scale", value)
	Globals.s_ui_scale = value
	ui_scale_label.text = "%sx" % value


func _on_ui_scale_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		get_tree().root.content_scale_factor = Globals.s_ui_scale


func _on_crosshair_size_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_crosshair_size = value
	crosshair_size_label.text = "%sx" % value


func _on_fov_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_fov_desired = value
	fov_label.text = "%s" % value


func _on_flares_check_toggled(button_pressed: bool) -> void:
	#_press_sound.play()
	Globals.s_flares_enabled = button_pressed


func _on_bloom_check_toggled(button_pressed: bool) -> void:
	#_press_sound.play()
	Globals.s_glow_enabled = button_pressed


func _on_c_bloom_check_toggled(button_pressed: bool) -> void:
	#_press_sound.play()
	Globals.s_cross_glow_enabled = button_pressed


func _on_volumetric_fog_check_toggled(button_pressed: bool) -> void:
	#_press_sound.play()
	Globals.s_volumetric_fog_enabled = button_pressed


func _on_snap_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_vertex_snap = floori(value)
	match floori(value):
		0:
			snap_label.text = "Off"
			ProjectSettings.set_setting("vertex_snap", -1)
			RenderingServer.global_shader_parameter_set("vertex_snap", -1)
		1:
			snap_label.text = "Tasteful"
			ProjectSettings.set_setting("vertex_snap", 0)
			RenderingServer.global_shader_parameter_set("vertex_snap", 0)
		2:
			snap_label.text = "Mild"
			ProjectSettings.set_setting("vertex_snap", 0.5)
			RenderingServer.global_shader_parameter_set("vertex_snap", 0.5)
		3:
			snap_label.text = "Moderate"
			ProjectSettings.set_setting("vertex_snap", 0.75)
			RenderingServer.global_shader_parameter_set("vertex_snap", 0.75)
		4:
			snap_label.text = "Intense"
			ProjectSettings.set_setting("vertex_snap", 0.875)
			RenderingServer.global_shader_parameter_set("vertex_snap", 0.875)
		5:
			snap_label.text = "Extreme"
			ProjectSettings.set_setting("vertex_snap", 0.9375)
			RenderingServer.global_shader_parameter_set("vertex_snap", 0.9375)
		6:
			snap_label.text = "Instant Modern Art"
			ProjectSettings.set_setting("vertex_snap", 0.96875)
			RenderingServer.global_shader_parameter_set("vertex_snap", 0.96875)


func _on_affine_warp_check_toggled(toggled_on: bool) -> void:
	#_press_sound.play()
	Globals.s_affine_warp = toggled_on
	ProjectSettings.set_setting("affine_warp", toggled_on)
	RenderingServer.global_shader_parameter_set("affine_warp", toggled_on)


func _on_palette_check_toggled(toggled_on: bool) -> void:
	#_press_sound.play()
	Globals.s_palette_compress_enabled = toggled_on


func _on_depth_slider_value_changed(_value: float) -> void:
	pass # Replace with function body.
