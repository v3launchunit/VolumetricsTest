extends VBoxContainer

@onready var difficulty_slider: HSlider = find_child("DifficultySlider")
@onready var difficulty_label: Label = find_child("DifficultyLabel")
@onready var _press_sound: AudioStreamPlayer = get_node("/root/GameMenu/ButtonPress")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	difficulty_slider.value = Globals.s_difficulty
	difficulty_label.text = "%s" % Globals.Difficulty.find_key(Globals.s_difficulty)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_difficulty_slider_value_changed(value: float) -> void:
	#_press_sound.play()
	Globals.s_difficulty = floori(value) as Globals.Difficulty
	difficulty_label.text = "%s" % Globals.Difficulty.find_key(Globals.s_difficulty)


func _on_difficulty_dropdown_item_selected(index: int) -> void:
	Globals.s_difficulty = index as Globals.Difficulty


func _on_intruder_check_toggled(toggled_on: bool) -> void:
	Globals.s_intruder = toggled_on
