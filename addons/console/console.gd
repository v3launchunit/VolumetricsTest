extends Node

var enabled := true
var enable_on_release_build := false : set = set_enable_on_release_build
var pause_enabled := false

signal console_opened
signal console_closed
signal console_unknown_command


enum CommandType {
	NORMAL,
	CHEAT,
	HIDDEN,
}


class ConsoleCommand:
	var function : Callable
	var arguments : PackedStringArray
	var required : int
	var description : String
	var type : CommandType
	func _init(
			in_function : Callable, 
			in_arguments : PackedStringArray, 
			in_required : int = 0, 
			in_description : String = "", 
			in_type := CommandType.NORMAL
	):
		function = in_function
		arguments = in_arguments
		required = in_required
		description = in_description


var control := Control.new()

# If you want to customize the way the console looks, you can direcly modify
# the properties of the rich text and line edit here:
var rich_label := RichTextLabel.new()
var line_edit := LineEdit.new()

var console_commands : Dictionary[String, ConsoleCommand] = {}
var console_aliases : Dictionary[String, String] = {}
var console_history := []
var console_history_index := 0
var was_paused_already := false

## Usage: Console.add_command("command_name", <function to call>, <number of arguments or array of argument names>, <required number of arguments>, "Help description")
func add_command(
		command_name : String, 
		function : Callable, 
		arguments = [], 
		required: int = 0, 
		description : String = "",
		type := CommandType.NORMAL,
) -> void:
	if arguments is int:
		# Legacy call using an argument number
		var param_array : PackedStringArray
		for i in range(arguments):
			param_array.append("arg_" + str(i + 1))
		console_commands[command_name] = ConsoleCommand.new(
				function, 
				param_array, 
				required, 
				description, 
				type
		)
		
	elif arguments is Array:
		# New array argument system
		var str_args : PackedStringArray
		for argument in arguments:
			str_args.append(str(argument))
		console_commands[command_name] = ConsoleCommand.new(
				function, 
				str_args, 
				required, 
				description, 
				type
		)


func remove_command(command_name : String) -> void:
	console_commands.erase(command_name)


func add_alias(command_alias: String, alias_of: String) -> void:
	console_aliases.set(command_alias, alias_of)


func add_aliases(command_aliases: Array[String], alias_of: String) -> void:
	for command_alias in command_aliases:
		console_aliases.set(command_alias, alias_of)


func remove_alias(command_alias : String) -> void:
	console_commands.erase(command_alias)


func remove_aliases(command_aliases: Array[String]) -> void:
	for command_alias in command_aliases:
		console_aliases.erase(command_alias)


func _enter_tree() -> void:
	var console_history_file := FileAccess.open("user://console_history.txt", FileAccess.READ)
	if (console_history_file):
		while (!console_history_file.eof_reached()):
			var line := console_history_file.get_line()
			if (line.length()):
				add_input_history(line)

	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 3
	add_child(canvas_layer)
	control.anchor_bottom = 1.0
	control.anchor_right = 1.0
	control.theme = load("res://ui/default_theme.tres")
	canvas_layer.add_child(control)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("000000d7")
	var style_f := StyleBoxFlat.new()
	style_f.bg_color = Color("00000000")
	rich_label.selection_enabled = true
	rich_label.context_menu_enabled = true
	rich_label.bbcode_enabled = true
	rich_label.scroll_following = true
	rich_label.anchor_right = 1.0
	rich_label.anchor_bottom = 0.5
	rich_label.add_theme_stylebox_override("normal", style)
	rich_label.add_theme_stylebox_override("focus", style_f)
	control.add_child(rich_label)
	rich_label.append_text("%s\n" % Globals.parse_text("console", "intro"))
	line_edit.anchor_top = 0.5
	line_edit.anchor_right = 1.0
	line_edit.anchor_bottom = 0.5
	line_edit.placeholder_text = "enter \"help\" for instructions"
	control.add_child(line_edit)
	line_edit.text_submitted.connect(on_text_entered)
	line_edit.text_changed.connect(on_line_edit_text_changed)
	control.visible = false
	process_mode = PROCESS_MODE_ALWAYS


func _exit_tree() -> void:
	var console_history_file := FileAccess.open("user://console_history.txt", FileAccess.WRITE)
	if (console_history_file):
		var write_index := 0
		var start_write_index := console_history.size() - 100 # Max lines to write
		for line in console_history:
			if (write_index >= start_write_index):
				console_history_file.store_line(line)
			write_index += 1


func _ready() -> void:
	add_command("exit", quit, 0, 0, "closes the game.")
	add_alias("quit", "exit")
	
	add_command("clear", clear, 0, 0, "clears the text on the console.")
	add_command("delete_history", delete_history, 0, 0, "deletes the history of previously entered commands.")
	add_alias("clear_history", "delete_history")
	add_command("help", help, 0, 0, "displays instructions on how to use the console.")
	
	add_command("commands_list", commands_list, 0, 0, "lists all commands and their descriptions.")
	add_alias("list_commands", "commands_list")
	add_aliases([
			"lcmd", 
			"lcmds", 
			"cmdl", 
			"cmdsl", 
			"l_cmd", 
			"l_cmds", 
			"cmd_l", 
			"cmds_l", 
			"list_cmd", 
			"list_cmds", 
			"cmd_list", 
			"cmds_list",
	], "commands_list")
	
	add_command("commands", commands, 0, 0, "lists commands with no descriptions.")
	add_aliases(["cmds", "cmd"], "commands")
	
	add_command("calc", calculate, ["mathematical expression to evaluate"], 0, "Evaluates the math passed in for quick arithmetic.")


func _input(event : InputEvent) -> void:
	if (event is InputEventKey):
		if (event.get_physical_keycode_with_modifiers() == KEY_QUOTELEFT): # ~ key.
			if (event.pressed):
				toggle_console()
			get_tree().get_root().set_input_as_handled()
		elif (event.physical_keycode == KEY_QUOTELEFT and event.is_command_or_control_pressed()): # Toggles console size or opens big console.
			if (event.pressed):
				if (control.visible):
					toggle_size()
				else:
					toggle_console()
					toggle_size()
			get_tree().get_root().set_input_as_handled()
		elif (event.get_physical_keycode_with_modifiers() == KEY_ESCAPE && control.visible): # Disable console on ESC
			if (event.pressed):
				toggle_console()
				get_tree().get_root().set_input_as_handled()
		if (control.visible and event.pressed):
			if (event.get_physical_keycode_with_modifiers() == KEY_UP):
				get_tree().get_root().set_input_as_handled()
				if (console_history_index > 0):
					console_history_index -= 1
					if (console_history_index >= 0):
						line_edit.text = console_history[console_history_index]
						line_edit.caret_column = line_edit.text.length()
						reset_autocomplete()
			if (event.get_physical_keycode_with_modifiers() == KEY_DOWN):
				get_tree().get_root().set_input_as_handled()
				if (console_history_index < console_history.size()):
					console_history_index += 1
					if (console_history_index < console_history.size()):
						line_edit.text = console_history[console_history_index]
						line_edit.caret_column = line_edit.text.length()
						reset_autocomplete()
					else:
						line_edit.text = ""
						reset_autocomplete()
			if (event.get_physical_keycode_with_modifiers() == KEY_PAGEUP):
				var scroll := rich_label.get_v_scroll_bar()
				var tween := create_tween()
				tween.tween_property(scroll, "value",  scroll.value - (scroll.page - scroll.page * 0.1), 0.1)
				get_tree().get_root().set_input_as_handled()
			if (event.get_physical_keycode_with_modifiers() == KEY_PAGEDOWN):
				var scroll := rich_label.get_v_scroll_bar()
				var tween := create_tween()
				tween.tween_property(scroll, "value",  scroll.value + (scroll.page - scroll.page * 0.1), 0.1)
				get_tree().get_root().set_input_as_handled()
			if (event.get_physical_keycode_with_modifiers() == KEY_TAB):
				autocomplete()
				get_tree().get_root().set_input_as_handled()


var suggestions := []
var current_suggest := 0
var suggesting := false
func autocomplete() -> void:
	if suggesting:
		for i in range(suggestions.size()):
			if current_suggest == i:
				line_edit.text = str(suggestions[i])
				line_edit.caret_column = line_edit.text.length()
				if current_suggest == suggestions.size() - 1:
					current_suggest = 0
				else:
					current_suggest += 1
				return
	else:
		suggesting = true
		
		var sorted_commands := []
		for command in console_commands:
			sorted_commands.append(str(command))
		sorted_commands.sort()
		sorted_commands.reverse()
		
		var prev_index := 0
		for command in sorted_commands:
			if command.contains(line_edit.text):
				var index : int = command.find(line_edit.text)
				if index <= prev_index:
					suggestions.push_front(command)
				else:
					suggestions.push_back(command)
				prev_index = index
		autocomplete()


func reset_autocomplete() -> void:
	suggestions.clear()
	current_suggest = 0
	suggesting = false


func toggle_size() -> void:
	if (control.anchor_bottom == 1.0):
		control.anchor_bottom = 1.9
	else:
		control.anchor_bottom = 1.0


func disable():
	enabled = false
	toggle_console() # Ensure hidden if opened


func enable():
	enabled = true


func toggle_console() -> void:
	set_console(!control.visible)


func set_console(to: bool) -> void:
	if (enabled):
		control.visible = to
	else:
		control.visible = false

	if (control.visible):
		was_paused_already = get_tree().paused
		get_tree().paused = was_paused_already || pause_enabled
		line_edit.grab_focus()
		console_opened.emit()
	else:
		control.anchor_bottom = 1.0
		scroll_to_bottom()
		reset_autocomplete()
		if (pause_enabled && !was_paused_already):
			get_tree().paused = false
		console_closed.emit()


func is_visible():
	return control.visible


func scroll_to_bottom() -> void:
	var scroll: ScrollBar = rich_label.get_v_scroll_bar()
	scroll.value = scroll.max_value - scroll.page


func print_error(text : String, print_godot := true) -> void:
	print_line("[color=light_coral]	   %s:[/color] %s" % [Globals.parse_text("console", "tag.err"), text], print_godot)


func print_blocked(text : String, print_godot := true) -> void:
	print_line("[color=#ff80ff]	   %s:[/color] %s" % [Globals.parse_text("console", "tag.blocked"), text], print_godot)


func print_line(text : String, print_godot := true) -> void:
	if (!rich_label): # Tried to print something before the console was loaded.
		call_deferred("print_line", text)
	else:
		rich_label.append_text(text)
		rich_label.append_text("\n")
		if (print_godot):
			print(text)


func parse_line_input(text : String) -> PackedStringArray:
	var out_array : PackedStringArray
	var first_char := true
	var in_quotes := false
	var escaped := false
	var token : String
	for c in text:
		if (c == '\\'):
			escaped = true
			continue
		elif (escaped):
			if (c == 'n'):
				c = '\n'
			elif (c == 't'):
				c = '\t'
			elif (c == 'r'):
				c = '\r'
			elif (c == 'a'):
				c = '\a'
			elif (c == 'b'):
				c = '\b'
			elif (c == 'f'):
				c = '\f'
			escaped = false
		elif (c == '\"'):
			in_quotes = !in_quotes
			continue
		elif (c == ' ' || c == '\t'):
			if (!in_quotes):
				out_array.push_back(token)
				token = ""
				continue
		token += c
	out_array.push_back(token)
	return out_array


func on_text_entered(new_text : String) -> void:
	scroll_to_bottom()
	reset_autocomplete()
	line_edit.clear()
	
	if not new_text.strip_edges().is_empty():
		add_input_history(new_text)
		print_line("[i]> " + new_text + "[/i]")
		var text_split := parse_line_input(new_text)
		var text_command := text_split[0]
		
		if console_aliases.has(text_command):
			text_command = console_aliases[text_command]
		
		if console_commands.has(text_command):
			var arguments := text_split.slice(1)
			
			# calc is a special command that needs special treatment
			if text_command.match("calc"):
				var expression := ""
				for word in arguments:
					expression += word
				console_commands[text_command].function.callv([expression])
				return
			
			if arguments.size() < console_commands[text_command].required:
				print_error("Too few arguments! Required < %d >" % console_commands[text_command].required)
				return
			elif arguments.size() > console_commands[text_command].arguments.size():
				print_error("Too many arguments! < %d > Max" % console_commands[text_command].arguments.size())
				return

			# Functions fail to call if passed the incorrect number of arguments, so fill out with blank strings.
			while (arguments.size() < console_commands[text_command].arguments.size()):
				arguments.append("")

			console_commands[text_command].function.callv(arguments)
		else:
			console_unknown_command.emit(text_command)
			print_error(Globals.parse_text("console", "fail.no"))


func on_line_edit_text_changed(new_text : String) -> void:
	reset_autocomplete()


func quit() -> void:
	get_tree().quit()


func clear() -> void:
	rich_label.clear()


func delete_history() -> void:
	console_history.clear()
	console_history_index = 0
	DirAccess.remove_absolute("user://console_history.txt")


func help() -> void:
	rich_label.append_text("	BUILT-IN COMMANDS:
		[color=light_green]calc[/color]: Calculates a given expresion
		[color=light_green]clear[/color]: Clears the registry view
		[color=light_green]commands[/color]: Shows a reduced list of all the currently registered commands
		[color=light_green]commands_list[/color]: Shows a detailed list of all the currently registered commands
		[color=light_green]delete_hystory[/color]: Deletes the commands history
		[color=light_green]quit[/color]: Quits the game
	CONTROLS:
		[color=light_blue]Up[/color] and [color=light_blue]Down[/color] arrow keys to navigate commands history
		[color=light_blue]PageUp[/color] and [color=light_blue]PageDown[/color] to scroll registry
		[[color=light_blue]Ctr[/color] + [color=light_blue]~[/color]] to change console size between half screen and full screen
		[color=light_blue]~[/color] or [color=light_blue]Esc[/color] key to close the console
		[color=light_blue]Tab[/color] key to autocomplete, [color=light_blue]Tab[/color] again to cycle between matching suggestions\n\n")


func calculate(command : String) -> void:
	var expression := Expression.new()
	var error = expression.parse(command)
	if error:
		print_error("%s" % expression.get_error_text())
		return
	var result = expression.execute()
	if not expression.has_execute_failed():
		print_line(str(result))
	else:
		print_error("%s" % expression.get_error_text())


func commands() -> void:
	var commands := []
	for command in console_commands:
		# only list commands that the player can actually use and aren't flagged as hidden
		if (
				console_commands[command].type == CommandType.HIDDEN
				or (console_commands[command].type == CommandType.CHEAT and not Globals.cheats_enabled)
				or console_commands[command].description == "" 
				or (
						console_commands[command].description.begins_with(Globals.parse_text("console", "desc.cheat_tag")) 
						and not Globals.cheats_enabled
				)
		):
			continue
		commands.append(str(command))
	commands.sort()
	rich_label.append_text("``	")
	rich_label.append_text(str(commands) + "\n\n")


func commands_list() -> void:
	var commands := []
	for command in console_commands:
		# only list commands that the player can actually use and aren't flagged as hidden
		if (
				console_commands[command].type == CommandType.HIDDEN
				or (console_commands[command].type == CommandType.CHEAT and not Globals.cheats_enabled)
				or console_commands[command].description == "" 
				or (
						console_commands[command].description.begins_with(Globals.parse_text("console", "desc.cheat_tag")) 
						and not Globals.cheats_enabled
				)
		):
			continue
		commands.append(str(command))
	commands.sort()
	
	for command in commands:
		var aliases_string := ""
		var arguments_string := ""
		var description : String = console_commands[command].description
		
		# get aliases
		var aliases: Array[String] = []
		for alias in console_aliases.keys():
			if console_aliases[alias] == command:
				aliases.append(alias)
		aliases.sort()
		for alias in aliases:
			aliases_string += ", " + alias
		
		# get arguments
		for i in range(console_commands[command].arguments.size()):
			if i < console_commands[command].required:
				arguments_string += " [color=cornflower_blue]<" + console_commands[command].arguments[i] + ">[/color]"
			else:
				arguments_string += " <" + console_commands[command].arguments[i] + ">"
		rich_label.append_text("	[color=light_green]%s%s[/color][color=gray]%s[/color]: %s\n" % [command, aliases_string, arguments_string, description])
	rich_label.append_text("\n")


func add_input_history(text : String) -> void:
	if (!console_history.size() || text != console_history.back()): # Don't add consecutive duplicates
		console_history.append(text)
	console_history_index = console_history.size()


func set_enable_on_release_build(enable : bool):
	enable_on_release_build = enable
	if (!enable_on_release_build):
		if (!OS.is_debug_build()):
			disable()
