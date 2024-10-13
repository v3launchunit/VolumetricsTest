extends Pickup


enum PowerupType {
	INVULN,
	BERSERK,
	FILTERS,
	FINGERS,
}


@export var duration: float = 30
@export var type := PowerupType.INVULN
@export var event_string: String = "pickup.invuln"


func _ready() -> void:
	if event_string and event_string != "":
		pickup_text = Globals.parse_text("events", event_string) % duration
	super()


func interact(body: Node3D) -> void:
	if body is Player:
		match type:
			PowerupType.INVULN:
				(body as Player).status.invuln_timer += duration
			PowerupType.BERSERK:
				(body as Player).status.berserk_timer += duration
			PowerupType.FILTERS:
				(body as Player).status.filters_timer += duration
			PowerupType.FINGERS:
				(body as Player).status.ff_timers.append(duration)
		picked_up(body)
