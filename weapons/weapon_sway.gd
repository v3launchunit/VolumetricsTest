extends Node3D


@export var rotate : bool = false


var look_vel := Vector2.ZERO


@onready var player := find_parent("Player") as Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_parent().position = Vector3(player.move_dir.x * player.strafe_sway, (
			player.move_dir.length() * player.sway_height / 6 * sin(2 * player.sway_speed * player.sway_timer) 
			if player.is_on_floor() 
			else clampf((-player.grav_vel.y) * player.jump_sway, -0.1, 0.1)
	), 0.0)
	#rotation.x = 
	look_vel = look_vel.lerp(Vector2(
			-player.look_dir.x, 
			-player.look_dir.y + clampf((-player.grav_vel.y * 0.1) * player.jump_sway, -0.01, 0.01)
	) * Globals.s_camera_sensitivity * player.camera_zoom_sens, delta * 3)
	rotation.y = look_vel.x * 3 - (180.0 if rotate else 0.0)
	rotation.x = look_vel.y * 3
