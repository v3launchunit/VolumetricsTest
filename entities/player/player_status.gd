class_name PlayerStatus
extends Status

signal key_acquired(key: int)

@export_category("PlayerStatus")

@export var max_armor: float = 100
@export_range(0, 1, 0.01) var armor_absorption := 0.5
## [AudioStream] to play upon taking damage.
@export var injury_stream: AudioStream

@export_storage var armor: float
@export_storage var held_keys: Array[bool] = [false, false, false]
@export_storage var powerups: Array[Powerup]
@export_storage var berserk_timer: float = 0.0
@export_storage var filters_timer: float = 0.0
@export_storage var invuln_timer: float = 0.0
@export_storage var ff_timers: PackedFloat64Array = []

@export_storage var god: bool = false
@export_storage var buddha: bool = false

@onready var stream_player := get_parent().get_node("AudioStreamPlayer") as AudioStreamPlayer
@onready var hud := get_parent().find_child("HUD") as HudHandler


func _enter_tree() -> void:
	add_console_commands()


func _exit_tree() -> void:
	remove_console_commands()


func _ready() -> void:
	health = max_health
	armor = max_armor / 4
	target_parent = get_parent()
	for i in (ripple_distance - 1):
		target_parent = target_parent.get_parent()
	key_acquired.connect(_on_key_acquired)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_give_max_health"):
		if health < 100.0:
			health = 100.0
		if armor < 25.0:
			armor = 25.0
		is_dead = false

	if Input.is_action_just_pressed("debug_give_max_armor"):
		if armor < 100.0:
			armor = 100.0
#	if health > max_health:
#		health -= overheal_decay_rate * delta
#		if health < max_health:
#			health = max_health


func _physics_process(delta: float) -> void:
	super(delta)
	if invuln_timer > 0:
		invuln_timer -= delta
	if berserk_timer > 0:
		berserk_timer -= delta
	if filters_timer > 0:
		filters_timer -= delta
	var i := 0
	while i < ff_timers.size():
		ff_timers.set(i, ff_timers[i] - delta)
		if ff_timers[i] <= 0:
			ff_timers.remove_at(i)
		else:
			i += 1


func damage_typed(amount: float, type: DamageType, _gib_mode: GibMode = GibMode.ALLOW_GIB) -> float: # returns damage dealt, for piercers
	if god or invuln_timer > 0:
		return amount # invulnerable players always stop piercers
	elif is_dead:
		return 0 # corpses cannot stop piercers
	hud.flash(Color(1, 0, 0, clamp(amount / 10, 0.1, 1)))
	if amount > 0:
		stream_player.stream = injury_stream
		stream_player.play()
	var damage_factor: float = damage_multipliers[type] if type != DamageType.ABSOLUTE else 1.0
	health -= amount * base_damage_factor * damage_factor * (1 - armor_absorption)
	#print(amount * base_damage_factor * damage_factor * (1 - armor_absorption))
	armor  -= amount * base_damage_factor * damage_factor * armor_absorption
	if armor < 0:
		health += armor # armor will be negative
		armor = 0
	if health <= 0:
		kill()
		return amount + health # health will be negative
	return amount # return value is amount of damage recieved, for piercers


func rapid_damage_typed(amount: float, type: DamageType, delta: float, _gib_mode: GibMode = GibMode.ALLOW_GIB) -> void:
	hud.rapid_flash(type, delta, god or invuln_timer > 0)
	if god or invuln_timer > 0:
		return
	var damage_factor: float = damage_multipliers[type] if type != DamageType.ABSOLUTE else 1.0
	health -= amount * delta * base_damage_factor * damage_factor * (1 - armor_absorption)
	armor  -= amount * delta * base_damage_factor * damage_factor * armor_absorption
	if armor <= 0:
		health += armor # armor will be negative
		armor = 0
	if health <= 0:
		kill()


# cannot telefrag players
func telefrag() -> bool:
	#kill()
	return false


func kill() -> void:
	is_dead = true
	died.emit()
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	if gibs != null:
		var e: Node = gibs.instantiate()
		target_parent.add_child(e)
		e.reparent(get_tree().current_scene)
		#move_child(exp, 0)
		get_parent().find_child("PlayerCam").switched_weapons.emit(-1, -1, false)
		get_parent().find_child("PlayerCam").current = false
		gibs = null


func heal(amount: float, can_overheal: bool = false, heal_armor: bool = false) -> bool:
	if not heal_armor and (health < max_health or can_overheal):
		health += amount
		return true
	if heal_armor and (armor < max_armor or can_overheal):
		armor += amount
		return true
	return false


func _on_key_acquired(key: int):
	held_keys[key] = true


#region console commands
func add_console_commands() -> void:
	Console.add_command("get_health", func(): Console.print_line("%f" % health), [], 0, Globals.parse_text("console", "desc.get_health"))
	Console.add_command("set_health", cmd_set_health, ["float value"], 1, Globals.parse_text("console", "desc.set_health"))
	Console.add_command("get_armor", func(): Console.print_line("%f" % armor), [], 0, Globals.parse_text("console", "desc.get_armor"))
	Console.add_command("set_armor", cmd_set_armor, [Globals.parse_text("console", "arg.float")], 1, Globals.parse_text("console", "desc.set_armor"))
	Console.add_command("get_absorption", func(): Console.print_line("%f" % armor_absorption), [], 0, Globals.parse_text("console", "desc.get_absorption"))
	Console.add_command("set_absorption", cmd_set_absorption, ["0-1 float value"], 1, Globals.parse_text("console", "desc.set_absorption"))
	Console.add_alias("get_abs", "get_absorption")
	Console.add_alias("set_abs", "set_absorption")
	Console.add_command("get_berserk", func(): Console.print_line("%f" % berserk_timer), [], 0, Globals.parse_text("console", "desc.get_berserk"))
	Console.add_alias("get_berzerk", "get_berserk")
	Console.add_command("get_invuln", func(): Console.print_line("%f" % invuln_timer), [], 0, Globals.parse_text("console", "desc.get_invuln"))
	Console.add_command("get_filters", func(): Console.print_line("%f" % filters_timer), [], 0, Globals.parse_text("console", "desc.get_filters"))
	Console.add_command("set_key", cmd_set_key, ["index of key to set (0 = red, 1 = green, 2 = blue)", "true/false"], 2, Globals.parse_text("console", "desc.set_key"))
	Console.add_command("kill", cmd_kill, [], 0, Globals.parse_text("console", "desc.kill"))
	Console.add_command("god", cmd_god, ["true/false"], 0, Globals.parse_text("console", "desc.god"))
	Console.add_command("buddha", cmd_buddha, ["true/false"], 0, Globals.parse_text("console", "desc.buddha"))


func remove_console_commands() -> void:
	Console.remove_command("get_health")
	Console.remove_command("set_health")
	Console.remove_command("get_armor")
	Console.remove_command("set_armor")
	Console.remove_command("get_absorption")
	Console.remove_command("set_absorption")
	Console.remove_aliases(["get_abs", "set_abs"])
	Console.remove_command("get_berserk")
	Console.remove_alias("get_berzerk")
	Console.remove_command("get_invuln")
	Console.remove_command("get_filters")
	Console.remove_command("set_key")
	Console.remove_command("kill")
	Console.remove_command("god")
	Console.remove_command("buddha")


func cmd_kill() -> void:
	kill()
	#GameMenu.close_top_menu(false)


func cmd_set_health(to: String) -> void:
	if Globals.try_run_cheat():
		health = to.to_float()
		Console.print_line(Globals.parse_text("console", "set") % ["health", to.to_float()])


func cmd_set_armor(to: String) -> void:
	if Globals.try_run_cheat():
		armor = to.to_float()
		Console.print_line(Globals.parse_text("console", "set") % ["armor", to.to_float()])


func cmd_set_absorption(to: String) -> void:
	if Globals.try_run_cheat():
		armor_absorption = to.to_float()
		Console.print_line(Globals.parse_text("console", "set") % ["armor_absorption", to.to_float()])


func cmd_set_key(which: String, to: String) -> void:
	if Globals.try_run_cheat():
		if not which.is_valid_int():
			Console.print_error(Globals.parse_text("console", "fail.bad_int") % "which")
			return
		if which.to_int() < 0 or which.to_int() > held_keys.size():
			Console.print_error(Globals.parse_text("console", "fail.bad_range") % "which")
		var to_b := Globals.get_pseudo_bool(to)
		if to_b == -1:
			Console.print_error(Globals.parse_text("console", "fail.bad_bool") % ["to", 0, held_keys.size()])
		held_keys[which.to_int()] = (to_b == Globals.PseudoBool.TRUE)


func cmd_god(to: String) -> void:
	if Globals.try_run_cheat():
		if to == "":
			god = not god
		else:
			var to_b := Globals.get_pseudo_bool(to)
			if to_b == -1:
				Console.print_error(Globals.parse_text("console", "fail.bad_bool") % to)
			else:
				god = (to_b == Globals.PseudoBool.TRUE)
		Console.print_line(Globals.parse_text("console", "god") % ("on" if god else "off"))


func cmd_buddha(to: String) -> void:
	if Globals.try_run_cheat():
		if to == "":
			buddha = not buddha
		else:
			var to_b := Globals.get_pseudo_bool(to)
			if to_b == -1:
				Console.print_error(Globals.parse_text("console", "fail.bad_bool") % to)
			else:
				buddha = (to_b == Globals.PseudoBool.TRUE)
		Console.print_line(Globals.parse_text("console", "buddha") % ("on" if buddha else "off"))
#endregion
