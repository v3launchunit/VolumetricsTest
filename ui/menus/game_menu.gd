extends Control

signal menu_closed(menu_layer: int)

var _active_menus: int = 0

@onready var _level_select_menu: Control = $LevelSelect
@onready var _settings_menu: Control = $Settings
@onready var _focus_sound: AudioStreamPlayer = $ScrollWheelMove
@onready var _hover_sound: AudioStreamPlayer = $ScrollWheelMove
@onready var _press_sound: AudioStreamPlayer = $ButtonPress
@onready var _unpress_sound: AudioStreamPlayer = $ButtonPress
@onready var _scroll_sound: AudioStreamPlayer = $ScrollWheelMove
#@onready var player: Player = get_tree().root.find_child("Player")
@onready var _save_button: Button = $VBoxContainer/Save
@onready var _save_file: FileDialog = $VBoxContainer/Save/SaveFile
@onready var _load_file: FileDialog = $VBoxContainer/Load/LoadFile


func _ready() -> void:
	visible = false
	_connect_audio()
	await get_tree().process_frame
	get_parent().move_child(self, -1)
	get_parent().child_entered_tree.connect(_on_root_child_entered_tree)
	Console.console_opened.connect(open_pause_menu)
	Console.console_closed.connect(_on_button_down)


func _process(_delta: float) -> void:
	_save_button.disabled = get_tree().current_scene is not Level 
	
	if _active_menus <= 0 and not get_tree().root.has_focus():
		open_pause_menu()
	if Input.is_action_just_pressed("ui_cancel"):
		if _active_menus <= 0:
			#_press_sound.play()
			open_pause_menu()
		else:
			close_top_menu()


func close_top_menu(with_sound: bool = true) -> void:
	if with_sound:
		_press_sound.play()
	menu_closed.emit(_active_menus)
	_active_menus -= 1
	if _active_menus <= 0:
		get_tree().paused = false
		hide()
		Globals.capture_mouse()
		_active_menus = 0


func open_pause_menu() -> void:
	get_parent().move_child(self, -1)
	_press_sound.play()
	if _active_menus >= 1:
		return
	get_tree().paused = true
	show()
	Globals.release_mouse()
	_active_menus = 1


## helper function to set up menu sounds
func _connect_audio() -> void:
	for n : Node in Globals.get_all_children(self):
		#if n is BaseButton or n is Range:
			#if not (n as Control).focus_entered.is_connected(_on_focus_entered):
				#(n as Control).focus_entered.connect(_on_focus_entered)
			#if not (n as Control).mouse_entered.is_connected(_on_mouse_entered):
				#(n as Control).mouse_entered.connect(_on_mouse_entered)
		
		if n is BaseButton:
			if not (n as BaseButton).button_down.is_connected(_on_button_down):
				(n as BaseButton).button_down.connect(_on_button_down)
			if not (n as BaseButton).button_up.is_connected(_on_button_up):
				(n as BaseButton).button_up.connect(_on_button_up)
			if n is OptionButton:
				if not (n as OptionButton).item_selected.is_connected(_on_item_selected):
					(n as OptionButton).item_selected.connect(_on_item_selected)
		elif n is Range:
			if not (n as Range).value_changed.is_connected(_on_range_value_changed):
				(n as Range).value_changed.connect(_on_range_value_changed)
			if (n is ScrollBar):
				if not (n as ScrollBar).drag_started.is_connected(_on_button_down):
					(n as ScrollBar).drag_started.connect(_on_button_down)
				if not (n as ScrollBar).drag_ended.is_connected(_on_button_up):
					(n as ScrollBar).drag_ended.connect(_on_button_up)


func _on_campaign_button_pressed() -> void:
	_level_select_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	_level_select_menu.show()
	_active_menus = 2


func _on_save_button_pressed() -> void:
	_save_file.current_file = "%s_%s_%s.scn" % [
			(get_tree().current_scene as Level).level_name,
			Time.get_date_string_from_system(), 
			Time.get_time_string_from_system(),
	]
	_save_file.show()
	#await _save_file.file_selected


func _on_save_file_file_selected(path: String) -> void:
	Globals.save_game(path)


func _on_load_button_pressed() -> void:
	_load_file.show()
	#await _load_file.file_selected


func _on_load_file_file_selected(path: String) -> void:
	Globals.open_level(load(path) as PackedScene)


func _on_settings_button_pressed() -> void:
	_settings_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	_settings_menu.show()
	_active_menus = 2


func _on_quit_button_pressed() -> void:
	_press_sound.play()
	get_tree().quit()


func _on_close_menu_button_pressed() -> void:
	close_top_menu(false)


#region menu audio
func _on_focus_entered() -> void:
	_hover_sound.play()


func _on_mouse_entered() -> void:
	_hover_sound.play()


func _on_button_down() -> void:
	_press_sound.play()


func _on_button_up() -> void:
	_unpress_sound.play()


func _on_item_selected(_index : int) -> void:
	_press_sound.play()


func _on_range_value_changed(_to : float) -> void:
	_scroll_sound.play()
#endregion menu audio


func _on_root_child_entered_tree() -> void:
	await get_tree().process_frame
	get_parent().move_child(self, -1)


func _on_console_opened() -> void:
	#if _active_menus > 1:
		#_active_menus += 1
	open_pause_menu()
