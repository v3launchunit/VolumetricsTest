extends MeshInstance3D

## The color of the halo.
@export var color: Color = Color.WHITE
## The time that the halo takes to fade in is one second divided by this.
@export var fade_in_speed: float = 10.0
## The time that the halo takes to fade out is one second divided by this.
@export var fade_out_speed: float = 2.0
@export_flags_3d_physics var collision_mask: int = 0b0000_1100_1000_0001

var player_cam: Camera3D
var was_hit: bool
var cam_old_pos := Vector3(0, -10, 0)

@onready var material: Material = material_override


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ignore_occlusion_culling = true
	material_override = material.duplicate()
	material = material_override
	Globals.settings_changed.connect(_on_globals_settings_changed)
	_on_globals_settings_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	material.albedo_color = color


func _physics_process(delta: float) -> void:
	color.a = move_toward(color.a, 0.0 if was_hit else 1.0, delta * fade_out_speed)

	if player_cam == null: #or not visible:
		player_cam = get_tree().get_first_node_in_group("player_cam")
		return

	if not (
			player_cam.is_inside_tree()
			and is_visible_in_tree()
			and randf() < Globals.C_FLARE_RE_EVAL_CHANCE
			and player_cam.global_position.distance_squared_to(cam_old_pos)
					> Globals.C_FLARE_RE_EVAL_DISTANCE_SQUARED
	):
		return

	var space_state = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
			global_position,
			player_cam.global_position,
			collision_mask,
	)
	var hit := space_state.intersect_ray(query)
	was_hit = true if hit else false # need ternary b/c hit technically isn't a bool
	cam_old_pos = player_cam.global_position


func _on_globals_settings_changed() -> void:
	visible = Globals.s_flares_enabled
