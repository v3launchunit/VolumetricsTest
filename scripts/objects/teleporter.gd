class_name Teleporter
extends Area3D

@export var func_godot_properties: Dictionary

@export_storage var configured: bool = true

@onready var to := find_child("Destination") as Marker3D

@onready var destination: Vector3 = find_child("Destination").global_position
@onready var nav_link: NavigationLink3D = find_child("NavigationLink3D")
@onready var streams: Array[Node] = find_children("AudioStreamPlayer3D")
@onready var tele_sys: Array[Node] = find_children("TeleportSys")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	if configured:
		return
	var dest := get_tree().get_first_node_in_group("targetname:%s" % func_godot_properties["target"]) as Marker3D
	if dest == null:
		return
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
	body.global_position = destination
	for stream in streams:
		stream.play()

	for sys in tele_sys:
		sys.emitting = true
		sys.restart()
#		sys.get_child(0).light_energy = 3.0
#		sys.get_child(0).show()


func set_destination(new_dest: Vector3) -> void:
	to.global_position = new_dest
	destination = new_dest
	nav_link.set_global_end_position(new_dest)
