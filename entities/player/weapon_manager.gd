class_name WeaponManager extends Camera3D


const ZOOM_SPEED: float = 10.0

@export var weapons: Array[Array] = [[], [], [], [], [], [], []]
@export var current_category: int = 0
@export var current_index: Array[int] = [0, 0, 0, 0, 0, 0, 0]
#@export var current_weapon: int = 0

## a dictionary of the maximum capacity for every type of ammunition.
@export var ammo_types: Dictionary[String, int] = {
	"shells": 50,
	"grenades": 25,
}
## a dictionary of the player's actual supply of each ammo type.
@export var ammo_amounts: Dictionary[String, int] = {
	"shells": 15,
	"grenades": 3,
}

#@export var anti_clip_speed: float = 7.5

#@export var anti_clip_collisions: int = 0
#@export var current_weapon_pos: float

#@export_group("Save Data")
@export_storage var prior_category: int = 0
@export_storage var prior_index: int = 0

@export_storage var target_fov: float = Globals.s_fov_desired
@export_storage var prior_fov: float = Globals.s_fov_desired
@export_storage var prior_zoom: float = 1.0

#@export var current_weapon_yaw_default: float

var fullbright_active : bool = false

#@onready var anti_clip_box := $ViewmodelAntiClip as Area3D
@onready var rummage_stream_player := $RummageStreamPlayer as AudioStreamPlayer

signal switched_weapons(category: int, index: int, with_safety_catch: bool)


func _enter_tree() -> void:
	add_console_commands()


func _exit_tree() -> void:
	remove_console_commands()


# Called when the node enters the scene tree for the first time.
func _ready():
	for key in ammo_amounts:
		ammo_amounts[key] = 0

	ammo_amounts["shells"] = 15
	ammo_amounts["grenades"] = 3

	switched_weapons.emit(current_category, current_index[current_category], true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if prior_fov != Globals.s_fov_desired:
		prior_fov = Globals.s_fov_desired
		scope_changed(prior_zoom)

	fov = lerpf(fov, target_fov, delta * ZOOM_SPEED)

	if Input.is_action_just_pressed("weapon_next"):
		_next_weapon()
	if Input.is_action_just_pressed("weapon_previous"):
		_previous_weapon()

	if Input.is_action_just_pressed("weapon_prior"):
		_select_weapon(prior_category, prior_index)

	if Input.is_action_just_pressed("weapon_1"):
		_select_category(0)
	if Input.is_action_just_pressed("weapon_2"):
		_select_category(1)
	if Input.is_action_just_pressed("weapon_3"):
		_select_category(2)
	if Input.is_action_just_pressed("weapon_4"):
		_select_category(3)
	if Input.is_action_just_pressed("weapon_5"):
		_select_category(4)
	if Input.is_action_just_pressed("weapon_6"):
		_select_category(5)
	if Input.is_action_just_pressed("weapon_7"):
		_select_category(6)

	if Input.is_action_just_pressed("debug_give_max_ammo"):
		for key in ammo_amounts:
			ammo_amounts[key] = ammo_types[key]

	#get_selected_weapon_node().rotation.y = lerpf(get_selected_weapon_node().rotation.y, current_weapon_yaw_default)
	#get_selected_weapon_node().position.z = move_toward(
			#get_selected_weapon_node().position.z,
			#get_selected_weapon_node().get_child(0).anti_clip_distance
					#if anti_clip_collisions > 0
					#else current_weapon_pos,
			#delta * anti_clip_speed)


func _next_weapon():
	prior_category = current_category
	prior_index = current_index[current_category]

	#get_selected_weapon_node().position.z = current_weapon_pos
	#get_selected_weapon_node().rotation.y = current_weapon_yaw_default
	current_index[current_category] += 1
	while (
			current_index[current_category] < weapons[current_category].size() and
			current_category > 0 and
			get_selected_weapon_path() == ^"Axe"
	):
		current_index[current_category] += 1
	while current_index[current_category] >= weapons[current_category].size():
		current_index[current_category] -= 1
		current_category += 1
		if current_category >= weapons.size():
			current_category = 0
		while weapons[current_category].is_empty():
			current_category += 1
			if current_category >= weapons.size():
				current_category = 0
		current_index[current_category] = 0
		while current_category > 0 and get_selected_weapon_path() == ^"Axe":
			current_index[current_category] += 1
			if current_index[current_category] >= weapons[current_category].size():
				current_index[current_category] -= 1
				current_category = (current_category + 1) % weapons.size()
				current_index[current_category] = 0
	#print("%s\n%s\n%s\n" % [current_category, current_index, get_selected_weapon_path()])
	switched_weapons.emit(current_category, current_index[current_category], false)
	#current_weapon_pos = get_selected_weapon_node().position.z
	#current_weapon_yaw_default = get_selected_weapon_node().rotation.y
	rummage_stream_player.play()


func _previous_weapon():
	prior_category = current_category
	prior_index = current_index[current_category]

	#get_selected_weapon_node().position.z = current_weapon_pos
	#get_selected_weapon_node().rotation.y = current_weapon_yaw_default
	current_index[current_category] -= 1
	while (
			current_index[current_category] >= 0 and
			current_category > 0 and
			get_selected_weapon_path() == ^"Axe"
	):
		current_index[current_category] -= 1
	while current_index[current_category] < 0:
		current_index[current_category] += 1
		current_category -= 1
		if current_category >= weapons.size():
			current_category = 0
		while weapons[current_category].is_empty():
			current_category -= 1
			if current_category < 0:
				current_category = weapons.size() - 1
		current_index[current_category] = weapons[current_category].size() - 1
		while current_category > 0 and get_selected_weapon_path() == ^"Axe":
			current_index[current_category] -= 1
			if current_index[current_category] < 0:
				current_index[current_category] = 0
				current_category -= 1

	switched_weapons.emit(current_category, current_index[current_category], false)
	#current_weapon_pos = get_selected_weapon_node().position.z
	#current_weapon_yaw_default = get_selected_weapon_node().rotation.y
	rummage_stream_player.play()


func _select_weapon(category: int, index: int) -> void:
	prior_category = current_category
	prior_index = current_index[current_category]

	#get_selected_weapon_node().position.z = current_weapon_pos
	#get_selected_weapon_node().rotation.y = current_weapon_yaw_default
	current_category = category
	current_index[category] = index
	switched_weapons.emit(category, index, true)
	#current_weapon_pos = get_selected_weapon_node().position.z
	#current_weapon_yaw_default = get_selected_weapon_node().rotation.y
	rummage_stream_player.play()


func _select_category(category: int) -> void:
	if weapons[category].is_empty():
		return
	prior_category = current_category
	prior_index = current_index[current_category]
	#get_selected_weapon_node().position.z = current_weapon_pos
	#get_selected_weapon_node().rotation.y = current_weapon_yaw_default
	if current_category == category:
		current_index[category] += 1
		if current_index[category] >= weapons[category].size():
			current_index[category] = 0
		while (
#				not current_index[category] >= weapons[category].size() and
				get_selected_weapon_path() == null
		):
			current_index[category] += 1
			if current_index[category] >= weapons[category].size():
				current_index[category] = 0
	else:
		current_category = category
		while (get_selected_weapon_path() == null):
			current_index[category] += 1
			if current_index[category] >= weapons[category].size():
				current_index[category] = 0
	switched_weapons.emit(category, current_index[category], false)
	#current_weapon_pos = get_selected_weapon_node().position.z
	#current_weapon_yaw_default = get_selected_weapon_node().rotation.y
	rummage_stream_player.play()


func has_ammo(type: String, amount: int = 1, virtual_charge: bool = false) -> bool:
	#print(ammo_amounts[type])
	if type == "none":
		return true
	if ammo_amounts[type] >= amount:
		if not virtual_charge:
			ammo_amounts[type] -= amount
		return true
	return false


func add_weapon(weapon: Node, weap: WeaponBase, _starting_ammo: int = 0) -> bool:
	#var weap: WeaponBase = weapon if weapon is WeaponBase else weapon.get_child(0)
	if (
			weapons[weap.category].is_empty() or
			weapons[weap.category].size() <= weap.index or
			weapons[weap.category][weap.index] == null
	):
		if weapons[weap.category].size() <= weap.index:
			weapons[weap.category].resize(weap.index + 1)
		weapons[weap.category][weap.index] = weapon
		#weapons[weap.category].pop_at(weap.index)
		#weapons[weap.category].insert(weap.index, weapon)

		_select_weapon(weap.category, weap.index)
		return true
	return false


func add_ammo(type: String, amount: int = 1) -> bool:
	if type != "none" and ammo_amounts[type] < ammo_types[type]:
		ammo_amounts[type] += amount
		return true
	return false


func force_add_ammo(type: String, amount: int = 1) -> void:
	if type != "none":
		ammo_amounts[type] += amount


func get_selected_weapon_node() -> Node3D:
	return get_node(get_selected_weapon_path())


func get_selected_weapon_path() -> NodePath:
	if (
			weapons[current_category].is_empty()
			or weapons[current_category][current_index[current_category]] == null
			or current_index[current_category] > weapons[current_category].size()
	):
		return ^"Axe"
	if weapons[current_category][current_index[current_category]] is NodePath:
		return weapons[current_category][current_index[current_category]]
	return weapons[current_category][current_index[current_category]].get_path()


func scope_changed(amount: float):
	prior_fov = Globals.s_fov_desired
	prior_zoom = amount
	target_fov = Globals.s_fov_desired / amount
	find_parent("Player").camera_zoom_sens = 1 / amount


#func on_viewmodel_anti_clip_body_entered(_body: Node3D):
	#anti_clip_collisions += 1
	#print("new body entered")
#
#
#func on_viewmodel_anti_clip_body_exited(_body: Node3D):
	#anti_clip_collisions -= 1
	#print("new body exited")


#region console commands

func add_console_commands() -> void:
	var ammo_types_names : String = "("
	
	for i: int in ammo_types.keys().size():
		if i > 0:
			ammo_types_names += ", "
		ammo_types_names += ammo_types.keys()[i]
	ammo_types_names += ")";
	
	Console.add_command(
			"get_ammo", 
			func(s: String): Console.print_line("%f" % ammo_amounts[s]), 
			[Globals.parse_text("console", "arg.ammo_type") % ammo_types_names], 
			1, 
			Globals.parse_text("console", "desc.get_ammo"),
	)
	Console.add_command(
			"set_ammo", 
			cmd_set_ammo, 
			[Globals.parse_text("console", "arg.ammo_type") % ammo_types_names, Globals.parse_text("console", "arg.int")], 
			2, 
			Globals.parse_text("console", "desc.set_ammo"),
			Console.CommandType.CHEAT,
	)
	#Console.add_command("fullbright", cmd_fullbright, [Globals.parse_text("console", "arg.bool")], 0, Globals.parse_text("console", "desc.fullbright"), Console.CommandType.CHEAT)


func remove_console_commands() -> void:
	Console.remove_command("get_ammo")
	Console.remove_command("set_ammo")
	#Console.remove_command("fullbright")


func cmd_set_ammo(type: String, to: int) -> void:
	if Globals.try_run_cheat():
		if not ammo_amounts.has(type):
			Console.print_error(Globals.parse_text("console", "fail.bad_ammo_type"))
			return
		ammo_amounts[type] = to


func cmd_fullbright(to: String) -> void:
	if Globals.try_run_cheat():
		if to == "":
			fullbright_active = not fullbright_active
		else:
			var to_b := Globals.get_pseudo_bool(to)
			if to_b == -1:
				Console.print_error(Globals.parse_text("console", "fail.bad_bool") % to)
				return
			else:
				fullbright_active = to_b == Globals.PseudoBool.TRUE
		Console.print_line(Globals.parse_text("console", "fullbright") % ("on" if fullbright_active else "off"))
		environment = load("uid://d387u5xga6b7") if fullbright_active else null


#endregion
