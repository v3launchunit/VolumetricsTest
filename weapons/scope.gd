extends Node3D

signal scope_changed(amount)

@export_category("Scope")

@export_range(1.0, 10.0, 0.5) var scope_strength: float = 2

#var cam: Camera3D
#var fov_desired: float
var attached_weapon: WeaponBase
var was_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
#	cam = get_viewport().get_camera_3d()
#	fov_desired = cam.fov
	attached_weapon = get_parent()
	scope_changed.connect(get_viewport().get_camera_3d().scope_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if attached_weapon.active and Input.is_action_just_pressed("weapon_fire_alt"):
		scope_changed.emit(scope_strength)
	
	if (
			was_active and 
			not attached_weapon.active
	) or Input.is_action_just_released("weapon_fire_alt"):
		scope_changed.emit(1)
	
	was_active = attached_weapon.active
#		cam.set_fov(fov_desired * scope_strength)
#	else:
#		cam.set_fov(fov_desired)
