@tool
class_name Teleporter
extends Area3D

@export var func_godot_properties: Dictionary
	#set(to):
		#func_godot_properties = to
		#await get_tree().process_frame

@export_storage var configured: bool = true
@export_storage var nav_link: NavigationLink3D

@onready var to := find_child("Destination") as Marker3D

@onready var destination: Vector3 = find_child("Destination").global_position
#@onready var nav_link: NavigationLink3D = find_child("NavigationLink3D")
@onready var streams: Array[Node] = find_children("AudioStreamPlayer3D")
@onready var tele_sys: Array[Node] = find_children("TeleportSys")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		#await get_tree().process_frame
		#get_parent().set_editable_instance(self, true)
		#print(get_parent().is_editable_instance(self))
		return
	
	add_to_group("targets:%s" %  func_godot_properties["target"], true)
	body_entered.connect(_on_body_entered)
	if func_godot_properties:
		var dest := get_tree().get_first_node_in_group("targetname:%s" % func_godot_properties["target"]) as Marker3D
		if dest == null:
			configured = false
			return
		to.global_position = dest.global_position
		destination = to.global_position
	nav_link.set_global_end_position(destination)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if nav_link == null and not func_godot_properties.is_empty():
		nav_link = NavigationLink3D.new()
		add_child(nav_link)
		nav_link.set_owner(owner)
		nav_link.position.y -= 0.5
		var dest := get_tree().get_first_node_in_group("targetname:%s" % func_godot_properties["target"]) as Marker3D
		if dest == null:
			print("destination could not be found")
			return
		print(dest)
		nav_link.set_global_end_position(dest.global_position)
		nav_link.end_position.y -= 0.5
		configured = true
		#set_destination(dest.global_position)
	if configured:
		#print("already configured")
		return
	var dest := get_tree().get_first_node_in_group("targetname:%s" % func_godot_properties["target"]) as Marker3D
	if dest == null:
		print("destination could not be found")
		return
	print(dest)
	nav_link.set_global_end_position(dest.global_position)
	set_destination(dest.global_position)
	configured = true
	#if properties and get_tree().has_group(properties["to"]):
		#to = get_tree().get_first_node_in_group(properties["to"]) as Node3D
		#if to != null:
			#destination = to.global_position
#	if tele_sys[0].get_child(0).visible:
#		for sys in tele_sys:
#			sys.get_child(0).light_energy -= delta
#			if sys.get_child(0).light_energy <= 0:
#				sys.get_child(0).hide()


func _on_body_entered(body: Node3D) -> void:
#	print("teleported " + body.name)
	#var colliders: Array[Node] = body.find_children("*", "PhysicsBody3D")
	#var state := get_world_3d().direct_space_state
	#for collider in colliders:
		#if body is PhysicsBody3D:
			#return
		#var params := PhysicsShapeQueryParameters3D.new()
		#params.shape = (body as PhysicsBody3D)
		#var result: Dictionary = state.intersect_shape(params)
	
	body.global_position = destination
	for stream in streams:
		stream.play()
	
	for sys in tele_sys:
		sys.emitting = true
		sys.restart()
#		sys.get_child(0).light_energy = 3.0
#		sys.get_child(0).show()


## Sets the teleporter's [membe r destination] to the specified [param new_dest].
func set_destination(new_dest: Vector3) -> void:
	to.global_position = new_dest
	destination = new_dest
	nav_link.set_global_end_position(new_dest)
