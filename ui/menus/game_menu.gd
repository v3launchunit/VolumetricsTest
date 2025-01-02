extends Control

var _active_menus: int = 0

@onready var _level_select_menu: Control = $LevelSelect
@onready var _settings_menu: Control = $Settings
@onready var _press_sound: AudioStreamPlayer = $ButtonPress
#@onready var player: Player = get_tree().root.find_child("Player")

signal menu_closed(menu_layer: int)


func _ready() -> void:
	visible = false
	
	for button in Globals.get_all_children(self):
		if button is not BaseButton or (button as BaseButton).button_down.is_connected(_on_button_down):
			continue
		(button as BaseButton).button_down.connect(_on_button_down)
	
	await get_tree().process_frame
	get_parent().move_child(self, -1)
	Console.console_opened.connect(open_pause_menu)
	Console.console_closed.connect(_on_button_down)


func _process(_delta: float) -> void:
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
	_press_sound.play()
	if _active_menus >= 1:
		return
	get_tree().paused = true
	show()
	Globals.release_mouse()
	_active_menus = 1


func _on_campaign_button_pressed() -> void:
	_level_select_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	_level_select_menu.show()
	_active_menus = 2


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


#func _on_load_button_pressed() -> void:
#	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	_settings_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	_settings_menu.show()
	_active_menus = 2


func _on_quit_button_pressed() -> void:
	_press_sound.play()
	get_tree().quit()


func _on_close_menu_button_pressed() -> void:
	close_top_menu(false)


func _on_button_down() -> void:
	_press_sound.play()


func _on_console_opened() -> void:
	#if _active_menus > 1:
		#_active_menus += 1
	open_pause_menu()
