#class_name GlobalsScript
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

#enum Lang {
	#ENGLISH,
#}

enum LevelStatus {
	HIDDEN,
	REVEALED,
	CLEARED,
}

enum PseudoBool {
	FALSE = 0,
	TRUE = 1,
	INVALID = -1,
}

#region constants
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
const C_PLAYER_MIN_HEIGHT: float = -1024.0

## The maximum amount of time an enemy can spend between wanderings.
const C_MAX_WANDER_IDLE_TIME : float = 10.0 
## The maximum amount of time an enemy can spend wandering at a time.
const C_MAX_WANDER_MOVE_TIME : float = 5.0

const C_LIZARD_HOLE_POINT := Vector3(0.0, -1000.0, 0.0)

## The filepath that user quicksaves are stored to.
const C_QUICKSAVE_PATH: String = "user://saves/auto/quicksave.scn"
## The filepath that persistent data (high scores, best times, what levels have
## been unlocked/cleared, etc) is stored to.
const C_PROGRESSION_PATH: String = "user://saves/progression.cfg"
## The filepath that user configuration settings are stored to.
const C_SETTINGS_PATH: String = "user://settings.cfg"
#endregion


#region settings
# ---------------------------------------------------------------------------- #
# --------------------------------- SETTINGS --------------------------------- #
# ---------------------------------------------------------------------------- #

#region visual settings
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
## The base vertical Field of View for the player's weapon viewmodels. 
## (high fov causes viewmodels to look stretched out and generally ugly).
var s_viewmodel_fov: float = 90

## The intensity of the PS1-style vertex snapping applied to certain objects.
var s_vertex_snap : int = 2
## Whether to apply PS1-style perspective-incorrect texture rendering.
var s_affine_warp : bool = true

## Toggles the mesh-based halos present on light sources and important objects.
var s_flares_enabled : bool = true
## Toggles the procedural halos created by the "glow" post-processing effect.
var s_glow_enabled : bool = false
## Toggles a procedural cross-shaped lens flare post-processing effect. I worked
## very hard on it.
var s_cross_glow_enabled : bool = true
## Toggles volumetric fog.
var s_volumetric_fog_enabled : bool = true
## Self-explanatory.
var s_brightness : float = 1.0
## Self-explanatory.
var s_contrast : float = 1.0
## Self-explanatory.
var s_saturation : float = 1.0
## Similar to brightness, but preserves the brightness values of black and white.
var s_gamma : float = 1.0

var s_palette_compress_enabled: bool = false
var s_color_depth: float = 16
var s_current_palette: String = "neutral"

## whether to enable "minor" light sources.
var s_minor_lights : bool = true
## whether to let "minor" objects cast shadows.
var s_minor_shadows : bool = false
## the shadow mode for "minor" objects.
var s_minor_shadows_mode := OmniLight3D.ShadowMode.SHADOW_CUBE

## The sensitivity multiplier applied to mouse movement with regards to the
## first-person camera.
var s_camera_sensitivity: float = 9.0
#endregion

#region audio settings
## Self-explanatory.
var s_master_volume: float = 70.0
## Self-explanatory.
var s_sound_volume: float = 100.0
## Self-explanatory.
var s_music_volume: float = 100.0
#endregion

#region Gameplay settings
## Self-explanatory.
var s_difficulty := Difficulty.NORMAL
## Nightmare mode is handled separately because it affects gameplay differently
## from the regular difficulty slider.
var s_nightmare: bool = false
## Whether the player loses their weapons and ammo between levels.
var s_intruder: bool = true
## Whether crouching is a toggle or a hold.
var s_toggle_crouch: bool = false
#endregion

#region Accessibility settings
## All loaded languages and their associated text files.
var langs: Dictionary[String, String]
## The game's current language.
var s_lang : String = "text_eng.cfg";
#endregion
#endregion


#region other
# ---------------------------------------------------------------------------- #
# ---------------------------------- OTHER ----------------------------------- #
# ---------------------------------------------------------------------------- #

## The [ConfigFile] used to associate names with filepaths.
var names := ConfigFile.new()
## The [ConfigFile] used to store text strings for the currently selected language.
var text := ConfigFile.new()
## The [ConfigFile] used to associated [PackedScene]s with campaign levels.
var campaign := ConfigFile.new()
## The [ConfigFile] used to store level-independent save data, such as high
## scores and campaign progress.
var progression := ConfigFile.new()
## functional universe number or whatever the hell it means in undertale. 
## rolled on startup, affects various things.
var fun := randi_range(1, 1000)
## whether the player is able to use [Console] commands categorized as "cheats".
var cheats_enabled: bool = false

## Whether the mouse is currently being captured by the program.
var mouse_captured: bool = false
#endregion


func _init() -> void:
	var err: Error = OK
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# load enemy names mapper
	err = names.load("res://names.cfg")
	assert(not err, "could not load names.cfg (error code %s)" % err)
	#if names.load("res://names.cfg"):
		#printerr("could not load names.cfg")
	
	# load language file
	err = text.load("res://text/%s" % s_lang)
	#if text.load("res://text/text_%s.cfg" % s_lang):
		#Console.print_error("could not load %s (error code %s)" % [s_lang, err])
	#assert(not err, "could not load %s (error code %s)" % [get_lang_name(s_lang), err])
	
	# load campaign mapper
	err = campaign.load("res://campaign.cfg")
	assert(not err, "could not load campaign.cfg (error code %s)" % err)
	#if campaign.load("res://campaign.cfg"):
		#printerr("could not load campaign.cfg")
	
	_setup_user()
	_load_config()
	progression.load(C_PROGRESSION_PATH)
	cheats_enabled = OS.has_feature("editor")


func _enter_tree() -> void:
	add_console_commands()


func _ready() -> void:
	# When the settings get changed, save them to disq.
	settings_changed.connect(_on_settings_changed)


#region console commands
func add_console_commands() -> void:
	Console.add_command("opensesame", open_sesame, [], 0, "", Console.CommandType.HIDDEN)
	Console.add_command("closesesame", close_sesame, [], 0, "", Console.CommandType.HIDDEN)
	Console.add_command("reload_text", reload_text, [], 0, parse_text("console", "desc.reload_text"))
	Console.add_command("open_level", cmd_map, ["level key"], 1, parse_text("console", "desc.map"), Console.CommandType.CHEAT)
	Console.add_alias("map", "open_level")
	Console.add_command("get_fun", cmd_fun, [], 0, "", Console.CommandType.HIDDEN)#, [], 0, parse_text("console", "desc.get_fun"))
	Console.add_command("set_fun", cmd_set_fun, ["0-1000 int value"], 1, "", Console.CommandType.HIDDEN)#, parse_text("console", "desc.set_fun"))
	Console.add_command("fun", cmd_fun, ["0-1000 int value"], 0, "", Console.CommandType.HIDDEN)
	Console.add_command("saves", func(): OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://saves/user"), true), [], 0, parse_text("console", "desc.saves"), Console.CommandType.NORMAL)
	


func open_sesame() -> void:
	if s_nightmare:
		Console.print_line(parse_text("console", "fail.blocked.nightmare"))
		OS.alert(
				parse_text("console", strip_bbcode("fail.blocked.nightmare")), 
				parse_text("console", "fail.blocked.nightmare.alert_title")
		)
		return
	elif cheats_enabled:
		Console.print_blocked(parse_text("console", "fail.blocked.redundant.opensesame"))
		return
	cheats_enabled = true
	Console.print_line(parse_text("console", "opensesame"))


func close_sesame() -> void:
	if s_nightmare:
		return
	elif not cheats_enabled:
		Console.print_blocked(parse_text("console", "fail.blocked.redundant.closesesame"))
		return
	cheats_enabled = false
	Console.print_line(parse_text("console", "closesesame"))


func reload_text() -> void:
	var err: Error = names.load("res://names.cfg")
	assert(not err, "could not load names.cfg (error code %s)" % err)


func cmd_fun(arg: String = "") -> void:
	print(arg)
	if try_run_cheat():
		if arg == "":
			Console.print_line("%d" % fun)
		elif not arg.is_valid_int() :
			Console.print_error(Globals.parse_text("console", "fail.bad_int") % "to")
		else:
			var to : int = arg.to_int()
			if not to >= 0 or not to <=1000:
				Console.print_error(Globals.parse_text("console", "fail.bad_range") % ["to", 0, 1000])
			else:
				fun = to


func cmd_set_fun(to: int) -> void:
	if try_run_cheat():
		fun = to


func cmd_map(level_key: String) -> void:
	if s_nightmare:
		Console.print_line(parse_text("console", "fail.blocked.nightmare"))
		return
	open_level_from_key(level_key)
#endregion


#func _physics_process(delta: float) -> void:
	#Engine.time_scale = smoothstep(Engine.time_scale, 1.0, delta / Engine.time_scale)


func load_languages() -> void:
	var config := ConfigFile.new()
	for item: String in ResourceLoader.list_directory("res://text"):
		config.load("res://text/%s" % item)
		if not langs.get(config.get_value("meta", "name")):
			langs.set(config.get_value("meta", "name"), item)


func get_lang_name(lang: String) -> String:
	return langs.get(lang, "text_eng.cfg")
	#match lang:
		#Lang.ENGLISH:
			#return "eng"
		#_:
			#return "eng"


## Reads the current configuration settings from disq and loads them into memory.
func _load_config() -> void:
	var config := ConfigFile.new()
	# Read from file and remember whether it was successful.
	var err: Error = config.load(C_SETTINGS_PATH)

	# If the file didn't load successfully (err != "OK"/0/false), ignore it and just
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
	s_minor_lights = config.get_value("video", "minor_lights_enabled", s_minor_lights)
	s_minor_shadows = config.get_value("video", "minor_light_shadows", s_minor_shadows)
	s_minor_shadows = config.get_value("video", "minor_shadows_mode", s_minor_shadows)

	s_master_volume = config.get_value("audio", "master_volume", s_master_volume)
	s_sound_volume = config.get_value("audio", "sound_volume", s_sound_volume)
	s_music_volume = config.get_value("audio", "music_volume", s_music_volume)


# Ensures that the expected filestructure exists within the user data folder.
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
	config.set_value("video", "minor_lights_enabled", s_minor_lights)
	config.set_value("video", "minor_light_shadows", s_minor_shadows)
	config.set_value("video", "minor_shadows_mode", s_minor_shadows)

	config.set_value("audio", "master_volume", s_master_volume)
	config.set_value("audio", "sound_volume", s_sound_volume)
	config.set_value("audio", "music_volume", s_music_volume)
	
	config.set_value("meta", "version", C_VERSION)

	config.save(C_SETTINGS_PATH) # Write to file.


## "Captures" the mouse, hiding it and preventing it from moving around.
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


## "Releases" the mouse, allowing it to move and render to the screen.
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Saves the level.
# TODO rework this system to actually work properly.
func save_game(to: String) -> void:
	var scene := PackedScene.new()
	var world = get_tree().current_scene
	if world is Level:
		(world as Level).loaded_from_savegame = true
	#var save_data := SaveData.new()
	for node: Node in get_all_children(world):
		if node.has_method("pre_save"):
			node.pre_save()
			if node.has_signal("ready_to_save"):
				await node.ready_to_save
		if node.has_method("save"):
			node.save()
		if node.owner == null:
			node.owner = world
		#save_data.save_node(node)
		#node.scene_file_path = ""
		#set_editable_instance(node, true)
	#save_data.name = "SaveData"
	#world.add_child(save_data)
	#save_data.owner = world
	scene.pack(world)
	assert(ResourceSaver.save(scene, to) == OK)


#region level management
## Loads the level assoiciated with [param level_key], as defined within in [code]campaign.cfg[/code].
func open_level_from_key(level_key: String) -> Error:
	var level := get_level_path(level_key)
	if level == "":
		Console.print_error(parse_text("console", "fail.bad_level") % level_key)
		return ERR_UNCONFIGURED
	var status := ResourceLoader.load_threaded_get_status(level)
	#if status != ResourceLoader.THREAD_LOAD_LOADED and status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		#print(status)
	if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE: # level has yet to be requested for loading
		return open_level(load(level)) # just forcefully load the thing
	elif status == ResourceLoader.THREAD_LOAD_FAILED: # level failed to load
		return ERR_CANT_ACQUIRE_RESOURCE
	else: # level is either loaded or in progress
		return open_level(ResourceLoader.load_threaded_get(level)) # fetch the level once it's ready


## Loads the specified [PackedScene].
func open_level(level: PackedScene) -> Error:
	#var screen_image := get_tree().root.get_texture()
	var err : Error = get_tree().change_scene_to_packed(level)
	#Console.print_line("loaded %s")
	#print(get_tree().current_scene)
	#if get_tree().current_scene is Level and (get_tree().current_scene as Level).fun != -1:
		#fun = (get_tree().current_scene as Level).fun
	#var world := get_tree().current_scene
	#if world.has_node("SaveData"):
		#(world.get_node("SaveData") as SaveData).load_all()
		#world.get_node("SaveData").queue_free()
	while GameMenu._active_menus > 0:
		GameMenu.close_top_menu()
	return err


## Returns the filepath associated with [param level_key], per [code]campaign.cfg[/code].
func get_level_path(level_key: String) -> String:
	return campaign.get_value(level_key.substr(0,2), level_key.substr(2), "")


# 0 = hidden
# 1 = revealed
# 2 = cleared
## Returns whether the specified level has been revealed yet. 
func level_revealed(level_name: String) -> bool:
	return progression.get_value("progress", "%s_status" % level_name, LevelStatus.HIDDEN) > LevelStatus.HIDDEN


## Returns whether the specified level has been cleared yet. 
func level_cleared(level_name: String) -> bool:
	return progression.get_value("progress", "%s_status" % level_name, LevelStatus.HIDDEN) > LevelStatus.REVEALED


func reveal_level(level_name: String) -> void:
	if level_name != "" and not level_revealed(level_name):
		progression.set_value("progress", "%s_status" % level_name, LevelStatus.REVEALED)
		progression.save(C_PROGRESSION_PATH)


func clear_level(level_name: String) -> void:
	if level_name != "" and not level_cleared(level_name):
		progression.set_value("progress", "%s_status" % level_name, LevelStatus.CLEARED)
		progression.save(C_PROGRESSION_PATH)


#endregion


## Returns the file path for the specified entry in [code]names.cfg[/code].
func parse_names(section: String, key: String) -> Variant:
	if section.ends_with("_paths") or section.ends_with("_aliases"):
		return names.get_value(section, key)
	else:
		return names.get_value(
				"%s_paths" % section, 
				names.get_value("%s_aliases" % section, key, key)
		)


## Returns the localized string assigned to the specified entry in [code]text_[lang].cfg[/code].
func parse_text(section: String, key: String) -> String:
	#print(text.get_value(section, key))
	var out := text.get_value(section, key, "MISSING: %s/%s" % [section, key]) as String
	if out.begins_with("MISSING: "):
		Console.print_error("language key %s/%s does not correspond to a valid %s entry!" % [section, key, get_lang_name(s_lang)])
	return out


func get_lut(lut_name: String) -> ImageTexture3D:
	var img := ImageTexture3D.new()
	var lut_path: String = names.get_value("Palettes", lut_name, "user palette")
	if (lut_path == "user palette"):
		lut_path = "user://palettes/%s" % [name]
	img.create(Image.FORMAT_RGB8, 64, 64, 64, false, [load(lut_path)])
	return img


## returns [param from] incremented or decremented by 1 towards [param to] 
## (eg. [code]intstep(1,5)[/code] returns 2).
func intstep(from: int, to: int) -> int:
	if from > to:
		return from - 1
	elif from < to:
		return from + 1
	else:
		return from


## Returns an [Array] containing all of that node's descendents, not just
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


## Helper function to define a generic "menu click" action, mostly for reloading 
## after a death or progressing from an intermission. 
func menu_click() -> bool:
	return Input.is_action_just_pressed("ui_click") or Input.is_action_just_pressed("interact")


## Returns [param from] with all BBCode tags removed.
func strip_bbcode(from : String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	return regex.sub(from, "", true)


## Unimplemented.
func uppercase(_string: String) -> String:
	var out: String = ""
	
	
	
	return out


## Returns whether cheats are enabled.
#func cheats_enabled() -> bool:
	#return OS.has_feature("editor") or (not s_nightmare)


## Converts a string to a [enum PseudoBool].
func get_pseudo_bool(s: String) -> PseudoBool:
	s = s.to_lower().strip_edges()
	for t in text.get_section_keys("console.true"):
		if s == t:
			return PseudoBool.TRUE
	for f in text.get_section_keys("console.false"):
		if s == f:
			return PseudoBool.FALSE
	return PseudoBool.INVALID


## Returns whether cheats are enabled, and logs an error message to the console if it is blocked.
func try_run_cheat() -> bool:
	if (cheats_enabled and not s_nightmare):
		return true
	elif s_nightmare:
		Console.print_line(parse_text("console", "fail.blocked.nightmare"))
		return false
	else:
		Console.print_blocked(parse_text("console", "fail.blocked.generic"))
		return false
