extends WeaponBase

signal ready_to_save

@export_category("Rifle")

## The time, in seconds, that the player must wait after loading a charge into
## the weapon before they may operate it again.
@export var _charge_delay: float = 1.0
@export var _label: Label


func _ready() -> void:
	if _label == null:
		_label = get_tree().get_first_node_in_group("hunting_rifle_label")
	else:
		_label.reparent(find_parent("Player").find_child("HUD"), false)
	super()


func _process(delta) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta

	if refire_penalty > 0:
		refire_penalty -= delta

	if (
			active
			and Input.is_action_pressed("weapon_fire_alt")
			and cooldown_timer <= 0
			and manager.has_ammo(ammo_type, ammo_cost * 2, true)
			and manager.has_ammo(ammo_type, ammo_cost)
	):
		_charge()

	if (
			active
			and (not safety_catch_active)
			and Input.is_action_pressed("weapon_fire_main")
			and cooldown_timer <= 0
	):
		if manager.has_ammo(ammo_type, ammo_cost):
			_fire()
		elif volley > 1:
			volley -= 1
			_fire()

	if safety_catch_active and not Input.is_action_pressed("weapon_fire_main"):
		safety_catch_active = false


func _fire() -> void:
	var base_scale = scale
#	spread = volley
	super()
	scale = base_scale

	volley = 1
#	spread = 0
	_label.text = "+0"#"1" if manager.has_ammo(ammo_type, ammo_cost, true) else "0"


func _pre_save() -> void:
	_label.reparent(self, false)
	emit_signal("ready_to_save")


func _charge() -> void:
	volley += 1
	_label.text = "+%s" % (volley - 1)
	cooldown_timer = _charge_delay
	state_machine.start("charging", true)


func _deploy(with_safety_catch: bool = true) -> void:
	super(with_safety_catch)
	_label.show()


func _holster() -> void:
	super()
	_label.hide()
