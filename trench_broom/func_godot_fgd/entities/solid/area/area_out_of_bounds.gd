class_name AreaOutOfBounds
extends Area3D


@export var func_godot_properties : Dictionary
@export var out_of_bounds_behavior := Level.OutOfBoundsBehavior.KILL
@export var reset_point : PathNode = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	out_of_bounds_behavior = func_godot_properties.get(
			"out_of_bounds_behavior", Level.OutOfBoundsBehavior.KILL
	).to_int()
	if func_godot_properties.get("target", "") != "":
		add_to_group("targets:%s" %  func_godot_properties["target"], true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if reset_point == null and func_godot_properties.get("target", "") != "":
		#origin = get_tree().get_first_node_in_group("targetname:%s" %  func_godot_properties["target"]) as PathNode
		reset_point = (get_tree().get_first_node_in_group(
				"targetname:%s" % func_godot_properties["target"]) as PathNode
		)


func _on_body_entered(body: Node3D) -> void:
	match out_of_bounds_behavior:
		Level.OutOfBoundsBehavior.KILL:
			if "status" in body:
				body.status.kill()
		Level.OutOfBoundsBehavior.WRAP:
			pass
		Level.OutOfBoundsBehavior.RESET:
			pass
