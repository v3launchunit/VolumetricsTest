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

@onready var stream_player := get_parent().get_node("AudioStreamPlayer") as AudioStreamPlayer
@onready var hud := get_parent().find_child("HUD") as HudHandler


func _enter_tree() -> void:
	add_console_commands()


func _ready() -> void:
	health = max_health
	armor = max_armor / 4
	target_parent = get_parent()
	for i in (ripple_distance - 1):
		target_parent = target_parent.get_parent()
	key_acquired.connect(_on_key_acquired)


func _exit_tree() -> void:
	remove_console_commands()
	

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


func damage_typed(amount: float, type: DamageType, gib_mode: GibMode = GibMode.ALLOW_GIB) -> float: # returns damage dealt, for piercers
	if invuln_timer > 0 or is_dead:
		return 0 # corpses cannot stop piercers
	hud.flash(Color(1, 0, 0, clamp(amount / 10, 0.1, 1)))
	if amount > 0:
		stream_player.stream = injury_stream
		stream_player.play()
	health -= amount * base_damage_factor * damage_multipliers[type] * (1 - armor_absorption)
	print(amount * base_damage_factor * damage_multipliers[type] * (1 - armor_absorption))
	armor  -= amount * base_damage_factor * damage_multipliers[type] * armor_absorption
	if armor < 0:
		health += armor # armor will be negative
		armor = 0
	if health <= 0:
		kill()
		return amount + health # health will be negative
	return amount # return value is amount of damage recieved, for piercers


func rapid_damage_typed(amount: float, type: DamageType, delta: float, gib_mode: GibMode = GibMode.ALLOW_GIB) -> void:
	if invuln_timer > 0:
		return
	health -= amount * delta * base_damage_factor * damage_multipliers[type] * (1 - armor_absorption)
	armor  -= amount * delta * base_damage_factor * damage_multipliers[type] * armor_absorption
	hud.rapid_flash(type, delta)
	if armor <= 0:
		health += armor # armor will be negative
		armor = 0
	if health <= 0:
		kill()


func kill() -> void:
	is_dead = true
	died.emit()
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	if gibs != null:
		var exp: Node = gibs.instantiate()
		target_parent.add_child(exp)
		exp.reparent(get_tree().current_scene)
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
	Console.add_command("get_health", func(): Console.print_line("%d" % health), [], 0, Globals.parse_text("console", "desc.get_health"))
	Console.add_command("set_health", cmd_set_health, ["float value"], 1, Globals.parse_text("console", "desc.set_health"))
	Console.add_command("get_armor", func(): Console.print_line("%d" % armor), [], 0, Globals.parse_text("console", "desc.get_armor"))
	Console.add_command("set_armor", cmd_set_armor, ["float value"], 1, Globals.parse_text("console", "desc.set_armor"))
	Console.add_command("get_absorption", func(): Console.print_line("%d" % armor_absorption), [], 0, Globals.parse_text("console", "desc.get_absorption"))
	Console.add_command("set_absorption", cmd_set_absorption, ["0-1 float value"], 1, Globals.parse_text("console", "desc.set_absorption"))
	Console.add_command("set_key", cmd_set_key, ["index of key to set (0 = red, 1 = green, 2 = blue)", "true/false"], 2, Globals.parse_text("console", "desc.set_key"))
	Console.add_command("kill", kill, [], 0, Globals.parse_text("console", "desc.kill"))


func remove_console_commands() -> void:
	Console.remove_command("get_health")
	Console.remove_command("set_health")
	Console.remove_command("get_armor")
	Console.remove_command("set_armor")
	Console.remove_command("get_absorption")
	Console.remove_command("set_absorption")
	Console.remove_command("set_key")
	Console.remove_command("kill")


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
		if not which.is_valid_float():
			Console.print_error(Globals.parse_text("console", "fail.bad_float") % "which")
			return
		if which.to_int() < 0 or which.to_int() > held_keys.size():
			Console.print_error(Globals.parse_text("console", "fail.bad_range") % "which")
		var to_b := Globals.get_pseudo_bool(to)
		if to_b == -1:
			Console.print_error(Globals.parse_text("console", "fail.bad_bool") % ["to", 0, held_keys.size()])
		held_keys[which.to_int()] = (to_b == Globals.PseudoBool.TRUE)
#endregion
