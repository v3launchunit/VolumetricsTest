extends VBoxContainer

@onready var sensitivity_slider: HSlider = find_child("SensitivitySlider")
@onready var sensitivity_label: Label = find_child("SensitivityLabel")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sensitivity_slider.value = Globals.s_camera_sensitivity
	sensitivity_label.text = "%04.1f" % Globals.s_camera_sensitivity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_sensitivity_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_camera_sensitivity = value
	sensitivity_label.text = "%04.1f" % Globals.s_camera_sensitivity
