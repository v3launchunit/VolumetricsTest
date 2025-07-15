extends Button

## The scene to load when this button is pressed.
@export var level_name: String
@export var always_open: bool = false
@export var is_secret: bool = false
@export var is_debug: bool = false

var level_path: String = ""
var _scene: PackedScene

#@onready var _press_sound: AudioStreamPlayer = GameMenu.get_node(^"ButtonPress")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_path = Globals.get_level_path(level_name)
	if level_path != "":
		ResourceLoader.load_threaded_request(level_path, type_string(typeof(PackedScene)))
		text = "%s -- %s" % [level_name.to_upper(), Globals.parse_text("levels", level_name)]
	
	if level_path == "" or not (
			always_open 
			or Globals.level_revealed(level_name)
			or OS.has_feature("editor")
	):
		disabled = true
		if is_secret or is_debug:
			visible = false
	pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#if Globals.mouse_captured:
		#Globals.release_mouse()


func check_unlocked() -> void:
	if level_path != "" and Globals.level_revealed(level_name):
		disabled = false
		if is_secret:
			visible = true


func _on_pressed() -> void:
	#_press_sound.play()
	if _scene == null:
		_scene = ResourceLoader.load_threaded_get(level_path)
	Globals.open_level(_scene)
