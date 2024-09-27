extends Area3D


@export var interact_sprite: Texture2D
@export var fade_speed = 2.0

var interacted: bool = false

@onready var mesh := $MeshInstance3D as MeshInstance3D
@onready var mat := mesh.material_override as StandardMaterial3D
@onready var player := $AudioStreamPlayer3D as AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interacted:
		mat.albedo_color.a = move_toward(mat.albedo_color.a, 0.0, fade_speed * delta)
		if mat.albedo_color.a <= 0.001 and not player.playing:
			queue_free()


func interact(body: Node3D) -> void:
	interacted = true
	mat.albedo_texture = interact_sprite
	player.play()
