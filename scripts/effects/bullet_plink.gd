extends Node

@export var damage_sys: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func damage(amount: float) -> float:
	if damage_sys != null:
		var instance := damage_sys.instantiate()
		get_parent().add_child(instance)
	return amount
