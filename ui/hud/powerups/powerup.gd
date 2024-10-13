class_name Powerup
extends TextureProgressBar


enum StackMode {
	STACK_EFFECT,
	STACK_TIMER,
	STACK_OVERWRITE
}


@export var stack_mode := StackMode.STACK_TIMER 
@export_range(0.0, 120.0, 0.1, "or_greater", "suffix:s") var duration : float = 60.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = duration
	value = duration
	custom_minimum_size.x = duration


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	duration -= delta
