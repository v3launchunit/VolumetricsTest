extends Node3D

@export_range(0.1, 30.0, 0.1, "or_greater") var camera_sens: float = 12

var look_dir: Vector2 # Input direction for look/aim

@onready var body: Node3D = find_child("PlayerCorpse")
@onready var camera: Camera3D = find_child("PlayerCam")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body.global_transform = global_transform
	camera.fov = Globals.s_fov_desired


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Engine.time_scale = move_toward(Engine.time_scale, 0.0, delta * 0.05)
	if (
			Input.is_action_just_pressed("interact")
			#or Input.is_action_just_pressed("ui_cancel")
	):
		get_tree().reload_current_scene()
		Engine.time_scale = 1.0
		queue_free()


#func _unhandled_input(event: InputEvent) -> void:
#	if event is InputEventMouseMotion:
#		look_dir = event.relative * 0.001
#		_rotate_camera(camera_sens)
#
#
#func _rotate_camera(sens_mod: float = 1.0) -> void:
##	print(camera.rotation)
#	body.rotation.y -= look_dir.x * camera_sens * sens_mod
#	camera.rotation.x -= look_dir.y * camera_sens * sens_mod
