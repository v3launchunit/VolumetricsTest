class_name PlayerStatus
extends Status

signal key_acquired(key: int)

@export_category("PlayerStatus")

@export var max_armor: float = 100
@export_range(0, 1, 0.01) var armor_absorption := 0.5
@export var injury_stream: AudioStream

@export var armor: float
@export var held_keys: Array[bool] = [false, false, false]

@onready var stream_player := get_parent().get_node("AudioStreamPlayer") as AudioStreamPlayer
@onready var hud := get_parent().find_child("HUD") as HudHandler


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	armor = max_armor / 4
	target_parent = get_parent()
	for i in (ripple_distance - 1):
		target_parent = target_parent.get_parent()
	key_acquired.connect(_on_key_acquired)


# Called every frame. 'delta' is the elapsed time since the previous frame.
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


func damage_typed(amount: float, type: DamageType, gib_mode: GibMode = GibMode.ALLOW_GIB) -> float: # returns damage dealt, for piercers
	if is_dead:
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
	health -= amount * delta * base_damage_factor * damage_multipliers[type] * (1 - armor_absorption)
	armor  -= amount * delta * base_damage_factor * damage_multipliers[type] * armor_absorption
	hud.rapid_flash(type, delta)
	if armor <= 0:
		health += armor # armor will be negative
		armor = 0
	if health <= 0:
		kill()


func kill():
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
