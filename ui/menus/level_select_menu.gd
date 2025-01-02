extends Control


func _on_back_button_pressed() -> void:
	find_parent("GameMenu").close_top_menu(false)
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_menu_closed(menu_layer: int) -> void:
	if menu_layer == 2:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
