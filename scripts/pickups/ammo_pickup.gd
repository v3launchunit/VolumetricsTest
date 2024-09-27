extends Pickup


@export var ammo_type: String = "none"
@export var ammo_amount: int = 1
@export var event_string: String = "pickup.ammo."


func _ready() -> void:
	if event_string and event_string != "":
		pickup_text = Globals.parse_text("events", event_string) % ammo_amount
	super()


func interact(body: Node3D) -> void:
	if (
			body.name == "Player"
			and body.find_child("PlayerCam").add_ammo(ammo_type, ammo_amount)
	):
		picked_up(body)
