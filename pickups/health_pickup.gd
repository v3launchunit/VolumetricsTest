extends Pickup


@export var heal_amount: float = 20.0
@export var can_overheal: bool = false
@export var is_armor_pickup: bool = false
@export var event_string: String = "pickup.health.gen"


func _ready() -> void:
	if event_string and event_string != "":
		pickup_text = Globals.parse_text("events", event_string) % ceili(heal_amount)
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func interact(body: Node3D) -> void:
	if body is Player and (body as Player).status.heal(
			heal_amount,
			can_overheal,
			is_armor_pickup
	):
		picked_up(body)
