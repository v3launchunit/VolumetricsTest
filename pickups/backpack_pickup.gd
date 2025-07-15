extends Pickup


@export var ammo_amount_overrides: Dictionary = {"rockets": 3}


func interact(body: Node3D) -> void:
	if body.name == "Player":
		var cam: WeaponManager = body.find_child("PlayerCam") as WeaponManager
		for key in cam.ammo_types:
			cam.force_add_ammo(
					key,
					ammo_amount_overrides[key]
					if ammo_amount_overrides.has(key)
					else cam.ammo_types[key]
			)
		picked_up(body)
