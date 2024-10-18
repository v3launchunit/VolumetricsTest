extends Node

## general scene-independent values and functions.
##
## this script is meant to hold various constants, global variables, user
## settings, etc. It also handles saving and loading user settings to and from
## the disq and a few other scene-independent things.

## tells scripts to check to see if the game's settings have been changed and
## to update any values they need to.
signal settings_changed
## tells scripts that they need to make sure everything is labeled correctly.
signal language_changed


enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	NIGHTMARE,
}

enum Lang {
	ENGLISH,
}

# ---------------------------------------------------------------------------- #
# --------------------------------- CONSTANTS -------------------------------- #
# ---------------------------------------------------------------------------- #

## The current build number.
const C_VERSION: String = "0.1.0.0"
## Error value for float equality comparisons (direct usage of == is generally
## discouraged because of floating-point precision errors resulting in numbers
## potentially being slightly off).
const C_EPSILON: float = 0.0001
## The percentage chance that a given enemy will check if it should re-evaluate
## its current path on a given frame (to prevent lag spikes from everyone
## recalculating their paths simultaneously).
const C_PATH_RE_EVAL_CHANCE: float = 0.1
## The total number of autoloads above the loaded level scene. Used so that
## instantiated scenes are correctly parented to the level scene, and by
## extension, do not persist between loading new scenes or reloading the
## current scene.
const C_AUTOLOAD_COUNT: int = 2
## The percentage chance that whether a given lens flare's visibility will be
## checked this frame.
const C_FLARE_RE_EVAL_CHANCE: float = 0.1
## The minimum distance that the player character must have traveled for lens
## flares to begin re-evaluating visibility, multiplied by itself to make the
## distance check slightly faster.
const C_FLARE_RE_EVAL_DISTANCE_SQUARED: float = 4.0
## If a hitscan tracer is shorter than this value, it will be deleted.
const C_HITSCAN_MIN_LENGTH: float = 0.125
const C_PLAYER_MIN_HEIGHT: float = -1000.0

## The maximum amount of time an enemy can spend between wanderings.
const C_MAX_WANDER_IDLE_TIME : float = 1.0 
## The maximum amount of time an enemy can spend wandering at a time.
const C_MAX_WANDER_MOVE_TIME : float = 1.0

const C_LIZARD_HOLE_POINT := Vector3(0.0, -1000.0, 0.0)

## The filepath that user quicksaves live in.
const C_QUICKSAVE_PATH: String = "user://saves/auto/quicksave.scn"

# ---------------------------------------------------------------------------- #
# --------------------------------- SETTINGS --------------------------------- #
# ---------------------------------------------------------------------------- #

# ---------- Visual settings ---------- #
## The screen's base resolution.
var s_resolution := Vector2i(1920, 1080)
## The screen's resolution is divided by this. Does not affect UI.
var s_stretch_scale: int = 2
## The screen's resolution is divided by this. Only affects UI.
var s_ui_scale: float = 1.0
## Scale multiplier for the ui crosshairs. 1.0 is 1:1 pixel-perfect with the
## output resolution.
var s_crosshair_size: float = 1.0

## The base vertical Field of View for the player's camera.
var s_fov_desired: float = 120
## Ditto. but for viewmodels (high fov causes viewmodels to look stretched out
## and generally ugly).
var s_viewmodel_fov: float = 90

var s_vertex_snap: int = 2
var s_affine_warp: bool = true

## Toggles the mesh-based halos present on light sources and important objects.
var s_flares_enabled: bool = true
## Toggles the procedural halos created by the "glow" post-processing effect.
var s_glow_enabled: bool = false
## Toggles a procedural cross-shaped lens flare post-processing effect. I worked
## very hard on it.
var s_cross_glow_enabled: bool = true
var s_volumetric_fog_enabled: bool = true
var s_palette_compress_enabled: bool = true
var s_color_depth: float = 16
var s_current_palette: String = "neutral"

## The sensitivity multiplier applied to mouse movement with regards to the
## first-person camera.
var s_camera_sensitivity: float = 12.0

# ---------- Audio settings ---------- #
## Self-explanatory.
var s_master_volume: float = 70.0
## Self-explanatory.
var s_sound_volume: float = 100.0
## Self-explanatory.
var s_music_volume: float = 100.0

# ---------- Gameplay settings ---------- #
## Self-explanatory.
var s_difficulty := Difficulty.NORMAL
## Nightmare mode is handled separately because it affects gameplay differently
## from the regular difficulty slider.
var s_nightmare: bool = false
## Whether the player gets to keep their weapons and ammo between levels.
var s_intruder: bool = true
## Whether crouching is a toggle or a hold.
var s_toggle_crouch: bool = false

# ---------- Accessibility settings ---------- #
var s_lang := Lang.ENGLISH

# ---------------------------------------------------------------------------- #
# ---------------------------------- OTHER ----------------------------------- #
# ---------------------------------------------------------------------------- #

var names := ConfigFile.new()
var text := ConfigFile.new()
var campaign := ConfigFile.new()
var persistent := ConfigFile.new()
var fun := randi_range(0, 999)

var mouse_captured: bool = false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if names.load("res://names.cfg"):
		printerr("could not load names.cfg")
	if text.load("res://text/text_%s.cfg" % get_lang_name(s_lang)):
		printerr("could not load text_%s.cfg")
	if campaign.load("res://campaign.cfg"):
		printerr("could not load campaign.cfg")
	_setup_user()
	_load_config()
	persistent.load("user://saves/persistent.cfg")


func _ready() -> void:
	# When the settings get changed, save them to disq.
	settings_changed.connect(_on_settings_changed)


#func _physics_process(delta: float) -> void:
	#Engine.time_scale = smoothstep(Engine.time_scale, 1.0, delta / Engine.time_scale)


func get_lang_name(lang: Lang) -> String:
	match lang:
		Lang.ENGLISH:
			return "eng"
		_:
			return "eng"


## Reads the current configuration settings from disq and loads them into memory.
func _load_config() -> void:
	var config := ConfigFile.new()
	# Read from file and remember whether it was successful.
	var err: Error = config.load("user://settings.cfg")

	# If the file didn't load successfully (err != "OK"/0), ignore it and just
	# keep the hardcoded defaults.
	if err:
		return

	s_resolution = config.get_value("video", "resolution", s_resolution)
	s_stretch_scale = config.get_value("video", "stretch_scale", s_stretch_scale)
	s_ui_scale = config.get_value("video", "ui_scale", s_ui_scale)
	s_crosshair_size = config.get_value("video", "crosshair_size", s_crosshair_size)
	s_fov_desired = config.get_value("video", "fov_desired", s_fov_desired)
	s_viewmodel_fov = config.get_value("video", "viewmodel_fov", s_viewmodel_fov)
	s_vertex_snap = config.get_value("video", "vertex_snap", s_vertex_snap)
	s_affine_warp = config.get_value("video", "affine_warp", s_affine_warp)
	s_flares_enabled = config.get_value("video", "flares_enabled", s_flares_enabled)
	s_glow_enabled = config.get_value("video", "glow_enabled", s_glow_enabled)
	s_cross_glow_enabled = config.get_value("video", "cross_glow_enabled",
			s_cross_glow_enabled)
	s_volumetric_fog_enabled = config.get_value("video", "volumetric_fog_enabled",
			s_volumetric_fog_enabled)
	s_palette_compress_enabled = config.get_value("video", "palette_compress_enabled",
			s_palette_compress_enabled)

	s_master_volume = config.get_value("audio", "master_volume", s_master_volume)
	s_sound_volume = config.get_value("audio", "sound_volume", s_sound_volume)
	s_music_volume = config.get_value("audio", "music_volume", s_music_volume)


func _setup_user() -> void:
	if not DirAccess.dir_exists_absolute("user://saves/auto"):
		DirAccess.make_dir_recursive_absolute("user://saves/auto")
	if not DirAccess.dir_exists_absolute("user://saves/user"):
		DirAccess.make_dir_recursive_absolute("user://saves/user")


func update_resolution() -> void:
	#s_resolution
	pass


## Save the current configuration settings to disq.
func _on_settings_changed() -> void:
	var config = ConfigFile.new()

	config.set_value("video", "resolution", s_resolution)
	config.set_value("video", "stretch_scale", s_stretch_scale)
	config.set_value("video", "ui_scale", s_ui_scale)
	config.set_value("video", "crosshair_size", s_crosshair_size)
	config.set_value("video", "fov_desired", s_fov_desired)
	config.set_value("video", "viewmodel_fov", s_viewmodel_fov)
	config.set_value("video", "vertex_snap", s_vertex_snap)
	config.set_value("video", "affine_warp", s_affine_warp)
	config.set_value("video", "flares_enabled", s_flares_enabled)
	config.set_value("video", "glow_enabled", s_glow_enabled)
	config.set_value("video", "cross_glow_enabled", s_cross_glow_enabled)
	config.set_value("video", "volumetric_fog_enabled", s_volumetric_fog_enabled)
	config.set_value("video", "palette_compress_enabled", s_palette_compress_enabled)

	config.set_value("audio", "master_volume", s_master_volume)
	config.set_value("audio", "sound_volume", s_sound_volume)
	config.set_value("audio", "music_volume", s_music_volume)
	
	config.set_value("meta", "version", C_VERSION)

	config.save("user://settings.cfg") # Write to file.


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


func save_game(to: String) -> void:
	var scene := PackedScene.new()
	var world = get_tree().current_scene
	if world is Level:
		(world as Level).loaded_from_savegame = true
	for node: Node in get_all_children(world):
		if node.has_method("pre_save"):
			node.pre_save()
			await node.ready_to_save
		node.owner = world
	scene.pack(world)
	push_error(ResourceSaver.save(scene, to))


func open_level_from_key(level_key: String) -> void:
	open_level(ResourceLoader.load_threaded_get(get_level_path(level_key)))


func open_level(level: PackedScene) -> void:
	#var screen_image := get_tree().root.get_texture()
	get_tree().change_scene_to_packed(level)
	#print(get_tree().current_scene)
	#if get_tree().current_scene is Level and (get_tree().current_scene as Level).fun != -1:
		#fun = (get_tree().current_scene as Level).fun
	while GameMenu._active_menus > 0:
		GameMenu.close_top_menu()

func parse_names(section: String, key: String) -> Variant:
	if section.ends_with("_paths") or section.ends_with("_aliases"):
		return names.get_value(section, key)
	else:
		return names.get_value(
				"%s_paths" % section, 
				names.get_value("%s_aliases" % section, key, key)
		)


func parse_text(section: String, key: String) -> String:
	#print(text.get_value(section, key))
	return text.get_value(section, key, "MISSING: %s/%s" % [section, key]) as String


func get_level_path(level_key: String) -> String:
	return campaign.get_value(level_key.substr(0,2), level_key.substr(2,2), "")


# 0 = hidden
# 1 = revealed
# 2 = cleared
func level_revealed(level_name: String) -> bool:
	return persistent.get_value("progress", "%s_status" % level_name, 0) > 0


func level_cleared(level_name: String) -> bool:
	return persistent.get_value("progress", "%s_status" % level_name, 0) > 1


func get_lut(lut_name: String) -> ImageTexture3D:
	var img := ImageTexture3D.new()
	var lut_path: String = names.get_value("Palettes", lut_name, "user palette")
	if (lut_path == "user palette"):
		lut_path = "user://palettes/%s" % [name]
	img.create(Image.FORMAT_RGB8, 64, 64, 64, false, [load(lut_path)])
	return img


## returns from incremented or decremented by 1 towards to
## (eg. intstep(1,5) returns 2)
func intstep(from: int, to: int) -> int:
	if from > to:
		return from - 1
	elif from < to:
		return from + 1
	else:
		return from


## returns an array containing all of that node's descendents, not just
## immediate children.
func get_all_children(node) -> Array:
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes


func menu_click() -> bool:
	return Input.is_action_just_pressed("ui_click") or Input.is_action_just_pressed("interact")


func uppercase(string: String) -> String:
	var out: String = ""
	
	
	
	return out
