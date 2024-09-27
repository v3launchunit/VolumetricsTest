extends Marker3D

## Properties:
## species - key to look up filepath to instanced scene
## ambush group - if not null, only instances associated scene after associated
## trigger is entered
@export var properties: Dictionary

var scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#rotation.y = deg_to_rad(float(properties.get("angle", 0)))
	scene = load(Globals.parse_rules("species", properties["species"]))
	if properties["ambush_group"] == "none":
		spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn() -> void:
	var instance: Node = scene.instantiate()
	add_child(instance)
	instance.reparent(get_tree().current_scene)
	queue_free()
