#@tool

class_name BrushDoor
extends AnimatableBody3D

enum DoorState {
	CLOSED,
	OPENING_0,
	OPENING_1,
	OPENING_2,
	OPEN,
	CLOSING_0,
	CLOSING_1,
	CLOSING_2,
}

signal interacted(with: Node3D)

@export var properties: Dictionary

@export_group("Save Data")
@export var open: bool = false
@export var start_pos := Vector3.INF
@export var audio_player: AudioStreamPlayer3D
@export var door_state: DoorState = DoorState.CLOSED
@export var lerp_timer: float = 0.0

var center := Vector3.UP * 1000.0
var nav_link: NavigationLink3D
var disabled: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if Engine.is_editor_hint():
		#return

	if start_pos == Vector3.INF:
		start_pos = global_position

	for point: Vector3 in get_child(1).shape.points:
		#center.x += point.x
		if point.y < center.y:
			center.y = point.y
		#center.z += point.z
	#center.x /= get_child(1).shape.points.size()
	center.x = position.x
	center.y += 0.5 - properties.get("open_pos").y
	center.z = position.z
	#center.z /= get_child(1).shape.points.size()
	
	if (properties["group"] as String).begins_with("fun."):
		open = (
				(properties["group"] as String).substr(4,3).to_int() <= Globals.fun 
				and (properties["group"] as String).substr(8,3).to_int() > Globals.fun
		)
		disabled = true
	elif properties.get("group") and properties["group"] != "none":
		for member in get_tree().get_nodes_in_group(properties["group"]):
			if member.has_signal("interacted"):
				member.interacted.connect(toggle)
			if member.has_method("on_triggered"):
				interacted.connect(member.on_triggered)
		add_to_group(properties.get("group"), true)

	if audio_player == null and properties.get("open_sound", "") != "":
		audio_player = AudioStreamPlayer3D.new()
		audio_player.bus = "World"
		audio_player.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_PHYSICS_STEP
		audio_player.stream = load(Globals.parse_names("sounds", properties.get("open_sound")))
		add_child(audio_player)
		#audio_player.position = properties.get("sound_pos") #* 0.0625
		#audio_player.position = get_child(1).shape.points[0]

	nav_link = NavigationLink3D.new()
	nav_link.start_position = center + properties.get("nav_link_offset")
	nav_link.end_position = center - properties.get("nav_link_offset")
	add_child(nav_link)
	#nav_link.reparent(get_tree().current_scene)


func _physics_process(delta: float) -> void:
	if nav_link != null:
		nav_link.enabled = open
	global_position = global_position.lerp(
			start_pos + properties.get("open_pos") if open else start_pos,
			delta * properties.get("open_speed")
	)
	
	#match door_state:
		#DoorState.CLOSED:
			#pass
		#DoorState.OPENING_0:
			#if properties["open_order"].x == 0:
				#global_position.x = lerpf(
						#global_position.x,
						#(start_pos + properties.get("open_pos")).x,
						#delta * properties.get("open_speed")
				#)
			#if properties["open_order"].y == 0:
				#global_position.y = lerpf(
						#global_position.y,
						#(start_pos + properties.get("open_pos")).y,
						#delta * properties.get("open_speed")
				#)
			#if properties["open_order"].z == 0:
				#global_position.z = lerpf(
						#global_position.z,
						#(start_pos + properties.get("open_pos")).z,
						#delta * properties.get("open_speed")
				#)
			#lerp_timer = lerpf(
					#lerp_timer,
					#1.0,
					#delta * properties.get("open_speed")
			#)
			#if is_equal_approx(lerp_timer, 1.0):
				#door_state = DoorState.OPENING_1
				#lerp_timer = 0.0
		#DoorState.OPENING_1:
			#if properties["open_order"].x == 1:
				#global_position.x = lerpf(
						#global_position.x,
						#(start_pos + properties.get("open_pos")).x,
						#delta * properties.get("open_speed")
				#)
			#if properties["open_order"].y == 1:
				#global_position.y = lerpf(
						#global_position.y,
						#(start_pos + properties.get("open_pos")).y,
						#delta * properties.get("open_speed")
				#)
			#if properties["open_order"].z == 1:
				#global_position.z = lerpf(
						#global_position.z,
						#(start_pos + properties.get("open_pos")).z,
						#delta * properties.get("open_speed")
				#)
			#lerp_timer = lerpf(
					#lerp_timer,
					#1.0,
					#delta * properties.get("open_speed")
			#)
			#if is_equal_approx(lerp_timer, 1.0):
				#door_state = DoorState.OPENING_2
				#lerp_timer = 0.0
		#DoorState.OPENING_2:
			#if properties["open_order"].x == 2:
				#global_position.x = lerpf(
						#global_position.x,
						#(start_pos + properties.get("open_pos")).x,
						#delta * properties.get("open_speed")
				#)
			#if properties["open_order"].y == 2:
				#global_position.y = lerpf(
						#global_position.y,
						#(start_pos + properties.get("open_pos")).y,
						#delta * properties.get("open_speed")
				#)
			#if properties["open_order"].z == 2:
				#global_position.z = lerpf(
						#global_position.z,
						#(start_pos + properties.get("open_pos")).z,
						#delta * properties.get("open_speed")
				#)
			#lerp_timer = lerpf(
					#lerp_timer,
					#1.0,
					#delta * properties.get("open_speed")
			#)
			#if is_equal_approx(lerp_timer, 1.0):
				#door_state = DoorState.OPEN
				#lerp_timer = 0.0
		#DoorState.OPEN:
			#pass
		#DoorState.CLOSING_0:
			#if is_equal_approx(properties["open_order"].x, 0):
				#global_position.x = lerpf(
						#global_position.x,
						#start_pos.x,
						#delta * properties.get("open_speed")
				#)
			#if is_equal_approx(properties["open_order"].y, 0):
				#global_position.y = lerpf(
						#global_position.y,
						#start_pos.y,
						#delta * properties.get("open_speed")
				#)
			#if is_equal_approx(properties["open_order"].z, 0):
				#global_position.z = lerpf(
						#global_position.z,
						#start_pos.z,
						#delta * properties.get("open_speed")
				#)
			#lerp_timer = lerpf(
					#lerp_timer,
					#1.0,
					#delta * properties.get("open_speed")
			#)
			#if is_equal_approx(lerp_timer, 1.0):
				#door_state = DoorState.CLOSING_1
				#lerp_timer = 0.0
		#DoorState.CLOSING_1:
			#if is_equal_approx(properties["open_order"].x, 1):
				#global_position.x = lerpf(
						#global_position.x,
						#start_pos.x,
						#delta * properties.get("open_speed")
				#)
			#if is_equal_approx(properties["open_order"].y, 1):
				#global_position.y = lerpf(
						#global_position.y,
						#start_pos.y,
						#delta * properties.get("open_speed")
				#)
			#if is_equal_approx(properties["open_order"].z, 1):
				#global_position.z = lerpf(
						#global_position.z,
						#start_pos.z,
						#delta * properties.get("open_speed")
				#)
			#lerp_timer = lerpf(
					#lerp_timer,
					#1.0,
					#delta * properties.get("open_speed")
			#)
			#if is_equal_approx(lerp_timer, 1.0):
				#door_state = DoorState.CLOSING_1
				#lerp_timer = 0.0
		#DoorState.CLOSING_2:
			#if is_equal_approx(properties["open_order"].x, 2):
				#global_position.x = lerpf(
						#global_position.x,
						#start_pos.x,
						#delta * properties.get("open_speed")
				#)
			#if is_equal_approx(properties["open_order"].y, 2):
				#global_position.y = lerpf(
						#global_position.y,
						#start_pos.y,
						#delta * properties.get("open_speed")
				#)
			#if is_equal_approx(properties["open_order"].z, 2):
				#global_position.z = lerpf(
						#global_position.z,
						#start_pos.z,
						#delta * properties.get("open_speed")
				#)
			#lerp_timer = lerpf(
					#lerp_timer,
					#1.0,
					#delta * properties.get("open_speed")
			#)
			#if is_equal_approx(lerp_timer, 1.0):
				#door_state = DoorState.CLOSED
				#lerp_timer = 0.0


func on_triggered(by: Node3D) -> void:
	toggle(by)


func get_tooltip() -> String:
	return (
			"" # inoperable and/or moving
			if (
					properties.get("secret", false)
					or not openable() 
					or (
							not open 
							and properties["tooltip_closed"] == ""
					)
					or (
							open 
							and properties["tooltip_open"] == ""
					)
					or (
					global_position.distance_squared_to(
							start_pos + properties.get("open_pos")
							if open
							else start_pos
					) > 0.1
			))
			else Globals.parse_text("tooltips", properties["tooltip_open"]) # opened
			if open
			else Globals.parse_text("tooltips", properties["tooltip_closed"]) # closed but not locked
	)


func interact(body: Node3D) -> void:
	if (
			Engine.is_editor_hint() 
			or (open and not properties["closeable"])
			or (
					door_state != DoorState.CLOSED 
					and door_state != DoorState.OPEN
			)
	):
		return
	if properties["required_key"] == -2 or (
			properties["required_key"] != -1 # door requires key
			and not body.find_child("Status").held_keys[properties["required_key"]] # player doesn't have the right key
	):
		if body is Player and not properties.get("secret", false):
			(body as Player).hud.set_alert(Globals.parse_text(
					"alerts", 
					"door.locked.%s" % properties["required_key"]
			))
		return
	else:
		interacted.emit(body)
		open = not open
		door_state = DoorState.OPENING_0 if open else DoorState.CLOSING_0
		audio_player.play()


func toggle(_body: Node3D) -> void:
	open = not open
	door_state = DoorState.OPENING_0 if open else DoorState.CLOSING_0
	if audio_player != null:
		audio_player.play()


func set_open(to: bool) -> void:
	if open != to:
		if audio_player != null:
			audio_player.play()
		door_state = DoorState.OPENING_0 if to else DoorState.CLOSING_0
	open = to


func openable() -> bool:
	return (
			not disabled
			and (
					#door_state == DoorState.CLOSED 
					not open
					or (
							#door_state == DoorState.OPEN
							open 
							and properties["closeable"]
					)
			)
			and properties["required_key"] != -2
	)
"res://trench_broom/func_godot_fgd/solid/func_door_solid_class.tres"
