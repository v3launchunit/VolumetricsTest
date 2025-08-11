extends Pickup


## The weapon that will be recieved upon collecting this pickup.
@export var weapon: PackedScene
## The amount of ammunition that will be recieved upon collecting this pickup.
## The recieved ammo's type is determined automatically based on the primary
## ammo of the associated weapon. If the player does not already possess this
## weapon, they are guarenteed to recieve the associated ammunition, regardless
## of how much ammo of that type they already possess.
@export var starting_ammo: int = 0
## Ditto, but for secondary-fire weapons. Ignored if the weapon is not
## [WeaponAltFire].
@export var starting_alt_ammo: int = 0
@export var event_string: String = "pickup.weap."


func _ready() -> void:
	if event_string and event_string != "":
		pickup_text = Globals.parse_text("events", event_string)
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func interact(body: Node3D) -> void:
	if body is Player:
		var manager := body.find_child("PlayerCam") as WeaponManager
		var instance := weapon.instantiate()
		var weap: WeaponBase = instance if instance is WeaponBase else instance.get_child(0).get_child(0)

		manager.get_node("WeaponsHolder").add_child(instance)

		if manager.add_weapon(instance, weap, starting_ammo):
			manager.force_add_ammo(weap.ammo_type, starting_ammo)
			if weap is WeaponAltFire:
				manager.force_add_ammo(weap.alt_ammo_type, starting_alt_ammo)
			picked_up(body)
		elif (
				manager.add_ammo(weap.ammo_type, starting_ammo)
				or weap is WeaponAltFire
				and manager.add_ammo(weap.alt_ammo_type, starting_alt_ammo)
		):
			instance.queue_free()
			picked_up(body)
		else:
			instance.queue_free()
