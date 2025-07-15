extends VBoxContainer

@onready var _master_slider: HSlider = find_child("MasterSlider") as HSlider
@onready var _master_label: Label = find_child("MasterLabel") as Label
#@onready var _master_preview: AudioStreamPlayer = find_child("MasterPreview") as AudioStreamPlayer
@onready var _master_bus: int = AudioServer.get_bus_index("Master")

@onready var _sound_slider: HSlider = find_child("SoundSlider")
@onready var _sound_label: Label = find_child("SoundLabel") as Label
#@onready var _sound_preview: AudioStreamPlayer = find_child("SoundPreview") as AudioStreamPlayer
@onready var _sound_bus: int = AudioServer.get_bus_index("Sound")

@onready var _music_slider: HSlider = find_child("MusicSlider") as HSlider
@onready var _music_label: Label = find_child("MusicLabel") as Label
#@onready var _music_preview: AudioStreamPlayer = find_child("MusicPreview") as AudioStreamPlayer
@onready var _music_bus: int = AudioServer.get_bus_index("Music")

#@onready var _press_sound: AudioStreamPlayer = get_node("/root/GameMenu/ButtonPress")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_master_slider.set_value_no_signal(Globals.s_master_volume)
	_master_label.text = "%s%%" % Globals.s_master_volume
	AudioServer.set_bus_volume_db(
			_master_bus,
			percent_to_decibels(Globals.s_master_volume)
	)

	_sound_slider.set_value_no_signal(Globals.s_sound_volume)
	_sound_label.text = "%s%%" % Globals.s_sound_volume
	AudioServer.set_bus_volume_db(
			_sound_bus,
			percent_to_decibels(Globals.s_sound_volume)
	)

	_music_slider.set_value_no_signal(Globals.s_music_volume)
	_music_label.text = "%s%%" % Globals.s_music_volume
	AudioServer.set_bus_volume_db(
			_music_bus,
			percent_to_decibels(Globals.s_music_volume)
	)


static func percent_to_decibels(input: float) -> float:
	return linear_to_db(input * 0.01)
	#return input * 0.6 - 60


func _on_master_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_master_volume = value
	_master_label.text = "%s%%" % value
	AudioServer.set_bus_volume_db(_master_bus, percent_to_decibels(value))
	#_master_preview.play()


func _on_sound_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_sound_volume = value
	_sound_label.text = "%s%%" % value
	AudioServer.set_bus_volume_db(_sound_bus,percent_to_decibels(value))
	#_sound_preview.play()


func _on_music_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_music_volume = value
	_music_label.text = "%s%%" % value
	AudioServer.set_bus_volume_db(_music_bus, percent_to_decibels(value))
	#_music_preview.play()
