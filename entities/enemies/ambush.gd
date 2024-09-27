class_name AmbushPoint3D 
extends Marker3D
## Instantiates a scene when the player enters the set area.


## The scene to be instantiated when this node's ambush is triggered.
@export var ambusher: PackedScene:
	set(p_ambusher):
		if p_ambusher != ambusher:
			ambusher = p_ambusher
			update_configuration_warnings()
## If true (and applicable), then this node's ambusher will have its target set
## to the ambushed player as soon as it is instantiated.
@export var auto_target: bool = false
## The vertical offset with which this node's ambusher is to be instantiated.
@export var y_offset: float = 1
## This node's ambush will be triggered as soon as a player enters this Area3D
## for the first time.
@export var trigger: Area3D:
	set(p_trigger):
		if p_trigger != trigger:
			trigger = p_trigger
			update_configuration_warnings()

@export var properties: Dictionary


func _ready() -> void:
	if properties:
		y_offset = 0
		ambusher = load(Globals.parse_names("species", properties["ambusher"]))
		#print((properties["group"] as String).begins_with("fun."))
		#print(Globals.fun)
		#print("%s: %s" % [name, (properties["group"] as String).substr(4,4).to_int()])
		#print("%s: %s" % [name, (properties["group"] as String).substr(9,4).to_int()])
		#print(
				#(properties["group"] as String).substr(4,4).to_int() <= Globals.fun 
				#and (properties["group"] as String).substr(9,4).to_int() > Globals.fun
		#)
		if (properties["group"] as String).begins_with("fun."):
			var fun: int = (get_tree().current_scene as Level).fun
			if fun < 0:
				fun = Globals.fun
			if (
					(properties["group"] as String).substr(4,3).to_int() <= fun 
					and (properties["group"] as String).substr(8,3).to_int() > fun
			):
				await get_tree().process_frame
				spawn_ambush()
			#else:
				#queue_free()
		elif properties.get("group", "none") != "none":
			for member in get_tree().get_nodes_in_group(properties["group"]):
				if member.has_signal("interacted"):
					member.interacted.connect(_on_trigger_body_entered)
			add_to_group(properties["group"], true)
	if trigger != null && ambusher != null:
		trigger.body_entered.connect(_on_trigger_body_entered)


func on_triggered(by: Node3D) -> void:
	_on_trigger_body_entered(by)


func _on_trigger_body_entered(_body: Node3D) -> void:
	if _body is Player:
		var a = spawn_ambush()
		if auto_target and a.has_method("detect_target"):
			a.detect_target(_body)


func spawn_ambush() -> Node3D:
	var a: Node3D = ambusher.instantiate()
	#print("instantiated ambusher")
	if "properties" in a:
		a.properties = properties.duplicate()
		#print("applied properties to ambusher")
	add_child(a)
	#print("placed ambusher in scenetree")
	a.position += Vector3(0, y_offset, 0)
	#print("offset ambusher")
	a.reparent(get_tree().current_scene)
	#print("placed ambusher in scene")
	if a is Hitscan:
		a.query_origin = a.global_position
	return a


func _get_configuration_warnings():
	var warnings = []
	if ambusher == null:
		warnings.append("This ambush does not have an ambusher set.")
	if trigger == null:
		warnings.append("This ambush does not have a trigger set.")
	# Returning an empty array means "no warning".
	return warnings
