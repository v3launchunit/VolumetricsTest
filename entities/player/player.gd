class_name Player extends CharacterBody3D


## Handles the player character.


@export_group("Movement")
## The player's base movement speed.
@export_range(0.0, 35.0, 0.1, "or_greater") var speed: float = 10.0
## The rate at which the player accelerates from standing still to moving at
## full speed.
@export_range(0.0, 100.0, 0.1, "or_greater") var acceleration: float = 100.0
## The absolute fastest that the player can travel in each direction.
@export var max_speed := Vector3(100.0, 100.0, 100.0)
## The rate at which the velocity imparted by sliding "decays" towards zero.
@export_range(0.0, 100.0, 0.1, "or_greater") var slide_drag: float = 10.0
## Ditto for knockback.
@export_range(0.0, 100.0, 0.1, "or_greater") var knockback_drag: float = 10.0
## Self-explanatory.
@export_range(0.1, 3.0, 0.1, "or_greater") var jump_height: float = 1
@export_range(1, 10, 1, "or_greater") var max_jumps: int = 1
@export_range(0.0, 100.0, 0.1, "or_greater") var rise_grav: float = 9.8
@export_range(0.0, 100.0, 0.1, "or_greater") var fall_grav: float = 9.8
@export_range(0.0, 100.0, 0.1, "or_greater") var slam_speed: float = 100.0
@export var slam_wave_scene: PackedScene

@export_group("Camera")
## The roll angle, in degrees, that the camera turns toward when strafing.
@export_range(0.0, 15.0, 0.1, "or_greater", "radians") var roll_intensity: float = 0.052
## The rate at which the camera tilt experiened while strafing is applied.
@export_range(0.0, 1.0, 0.001) var roll_speed: float = 0.5

## The frequency of the camera's horizontal movement when walking.
@export_range(0.0, 10.0, 0.1, "or_greater") var sway_speed: float = 5.0
## The amplitude of the camera's horizontal movement when walking. (The camera's
## vertical amplitude is half this, resulting in the camera moving in a
## figure-eight pattern.)
@export_range(0.0, 1.0, 0.001) var sway_height: float = 0.3
## While airborne, the weapon's apparent position (produced by manipulating the
## camera's transform position and vertical offset) corresponds to the player's
## current falling speed, multiplied by this.
@export_range(0.0, 1.0, 0.001) var jump_sway: float = 0.01
@export_range(0.0, 1.0, 0.001) var strafe_sway: float = 0.025
@export_range(-1.0, 1.0, 0.01) var look_drag: float = 0.25

@export_group("Sounds")
## The audio stream that plays when the player attempts to interact with an
## interactable object.
@export var interact_stream: AudioStream
## The audio stream that plays when the player jumps.
@export var jump_stream: AudioStream
## The audio stream that plays when the player performs a slide.
@export var slide_stream: AudioStream
#@export var slam_land_stream: AudioStream

@export_group("Save Data")
## Whether the player has a pending jump request.
@export_storage var jumping: bool = false
## Whether the player is currently crouching.
@export_storage var crouching: bool = false
## Whether the player is currently slamming.
@export_storage var slamming: bool = false
## How long the player has been slamming for.
@export_storage var slam_timer: float = 0.0
## How long the player can remain grounded before losing the post-slam jump boost.
@export_storage var slam_decay: float = 1.0

## The maximum number of times that the player can jump before landing.
@export_storage var jumps: int = 1
@export_storage var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_storage var move_dir: Vector2 ## Input direction for movement.
@export_storage var look_dir: Vector2 ## Input direction for look/aim.

@export_storage var walk_vel: Vector3 ## The current walking velocity vector.
@export_storage var slide_vel: Vector3 ## The current sliding velocity vector.
@export_storage var grav_vel: Vector3 ## The current gravity velocity vector.
#@export_storage var jump_vel: Vector3 ## The current jumping velocity vector.
@export_storage var knockback_vel: Vector3 ## The current knockback velocity vector.

@export_storage var camera_zoom_sens: float = 1.0
@export_storage var reorienting: bool = false
@export_storage var sway_timer: float = PI/2

@export_storage var cam_recoil_pos: float = 0.0
@export_storage var cam_recoil_vel: float = 0.0

@export_storage var holding = null

@export_storage var noclip: bool = false

#var listening_for_cheats: bool = false
var cam_y_offset: float = 0.0
var crouch_speed: float = 15.0

@onready var camera := find_child("PlayerCam") as WeaponManager
@onready var camera_sync := find_child("PlayerSync") as Node3D
@onready var flashlight := find_child("Flashlight") as SpotLight3D
@onready var status := $Status as PlayerStatus
@onready var hitbox := $PlayerHitbox as CollisionShape3D
@onready var crouchbox := $PlayerCrouchHitbox as CollisionShape3D
@onready var interact_scan := find_child("Interact") as RayCast3D
@onready var clearance_scan := $ClearanceCast as ShapeCast3D
@onready var floor_snap_cast := $FloorSnapCast as RayCast3D
@onready var stream_player := $AudioStreamPlayer as AudioStreamPlayer
@onready var slam_wind_sys := find_child("SlamWindSys") as GPUParticles3D
@onready var slam_wave_spawner := find_child("SlamWaveSpawner") as Marker3D
@onready var hud := find_child("HUD") as HudHandler


func _enter_tree() -> void:
	add_console_commands()


func _ready() -> void:
	Globals.capture_mouse()


func _process(_delta) -> void:
	if jumps < max_jumps and is_on_floor():
		jumps = max_jumps

	if not noclip and Input.is_action_pressed("jump") and jumps > 0:
		stream_player.stream = jump_stream
		stream_player.play()
		jumping = true

	if crouching and (
			noclip
			or (
					Globals.s_toggle_crouch
					and Input.is_action_just_pressed("crouch")
			) or not (
					Globals.s_toggle_crouch
					or Input.is_action_pressed("crouch")
			)
	) and not clearance_scan.is_colliding():
		_toggle_crouch(false)

	if interact_scan.is_colliding():
		if (
				interact_scan.get_collider()
				and interact_scan.get_collider().has_method("get_tooltip")
				and interact_scan.get_collider().get_tooltip() != ""
		):
			hud.tooltip.visible = true
			hud.set_tooltip(interact_scan.get_collider().get_tooltip())
		else:
			hud.tooltip.visible = false
		
		# Check if I should interact with anything
		if (
				interact_scan.get_collider()
				and Input.is_action_just_pressed("interact") 
				and interact_scan.get_collider().has_method("interact")
		):
			interact_scan.get_collider().interact(self)
			stream_player.stream = interact_stream
			stream_player.play()
	else:
		hud.tooltip.visible = false

	if Input.is_action_just_pressed("crouch") and not (crouching or noclip):
		if not is_on_floor() and not Input.is_action_pressed("jump"):
			if floor_snap_cast.is_colliding():
				apply_floor_snap()
				_toggle_crouch(true)
			else:
				slamming = true
		else:
			_toggle_crouch(true)

	if Input.is_action_just_pressed("quick_restart"):
		#get_tree().reload_current_scene()
		Globals.open_level_from_key((get_tree().current_scene as Level).level_key)

	if Input.is_action_just_pressed("quick_save"):
		Globals.save_game(Globals.C_QUICKSAVE_PATH)

	if Input.is_action_just_pressed("quick_load"):
		var q: PackedScene = load(Globals.C_QUICKSAVE_PATH)
		if q != null:
			get_tree().change_scene_to_packed(q)

	slam_wind_sys.visible = slamming
	
	#if Input.is_key_label_pressed(KEY_V):
		#listening_for_cheats = true


func _physics_process(delta: float) -> void:
	if noclip:
		_physics_process_noclip(delta)
	else:
		_physics_process_default(delta)


func _physics_process_default(delta: float) -> void:
	
	camera.rotation.x = fposmod(camera.rotation.x + PI, 2 * PI) - PI
	
	# Check if my camera rotation is valid
	if is_on_floor() and not reorienting and (
			camera.rotation.x < -PI / 2 or
			camera.rotation.x > PI / 2
	):
		reorienting = true

	# If not, perform somersaults until it is
	if reorienting:
		camera.rotation.x -= PI * delta
		if camera.rotation.x < -PI: # To prevent excessive somersaulting
			camera.rotation.x += 2 * PI
		if camera.rotation.x > PI: # To prevent excessive somersaulting
			camera.rotation.x -= 2 * PI
		# To prevent eternal somersaulting
		if abs(camera.rotation.x) < 0.1:
			reorienting = false
	
	# Handle actually moving
	velocity = (
			_walk(delta)
			+ _slide(delta)
			+ _gravity(delta)
			#+ _jump(delta)
			+ _knockback(delta)
	)
	
	# Handle joypad look
	if Globals.mouse_captured: 
		_handle_joypad_camera_rotation(delta)
	
	#cam_recoil_pos = camera_sync.rotation.x + cam_recoil_vel
	#cam_recoil_pos = smoothstep(camera_sync.rotation.x + cam_recoil_vel * delta, 0, delta)
	# reset camera sync's transform to align with the player's 
	# (needed because a subviewport breaks 3d transform inheritance)
	camera_sync.global_transform = global_transform
	# handle y offset
	camera_sync.position.y += cam_y_offset
	cam_y_offset = lerpf(cam_y_offset, 0.0, delta * crouch_speed)
	# handle pitch recoil
	if is_equal_approx(cam_recoil_vel, 0.0):
		cam_recoil_pos = lerpf(cam_recoil_pos, 0.0, delta * 3)
	else:
		cam_recoil_pos += cam_recoil_vel * delta
	cam_recoil_vel = move_toward(cam_recoil_vel, 0.0, delta * 3)
	camera_sync.rotation.x = cam_recoil_pos

	velocity = velocity.clamp(-max_speed, max_speed)
	
	var forward_test: bool = test_move(global_transform, velocity)
	if forward_test:
		var slope_test: bool = test_move(global_transform, (velocity + velocity.length() * Vector3.UP) * delta)
		if slope_test:
			var step_pos := global_transform
			step_pos.origin.y += 0.5
			var step_test: bool = test_move(global_transform, Vector3.UP * 0.5) or test_move(step_pos, velocity * delta)
			if not step_test:
				position.y += 0.5
				cam_y_offset -= 0.5
	
	move_and_slide()
	
	if global_position.y < Globals.C_PLAYER_MIN_HEIGHT:
		match (get_tree().current_scene as Level).bounds_behavior:
			Level.BoundsBehavior.KILL:
				if status.god or status.buddha:
					global_position = Vector3.ZERO
					grav_vel = Vector3.ZERO
				else:
					status.kill()
			Level.BoundsBehavior.WRAP:
				global_position.y = -Globals.C_PLAYER_MIN_HEIGHT
				grav_vel = Vector3.ZERO
			Level.BoundsBehavior.RESET:
				global_position = Vector3.ZERO
				grav_vel = Vector3.ZERO


func _physics_process_noclip(delta: float) -> void:
	velocity = _fly(delta)
	camera_sync.global_transform = global_transform
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if Globals.mouse_captured:
			_rotate_camera(camera_zoom_sens)


func _exit_tree() -> void:
	remove_console_commands()


## Actually rotates the player [Camera3D].
func _rotate_camera(sens_mod: float = 1.0) -> void:
	var sens: float = Globals.s_camera_sensitivity * sens_mod
	rotation.y -= look_dir.x * sens
	if is_on_floor() and not reorienting:
		camera.rotation.x = clampf(camera.rotation.x - look_dir.y * sens, -1.5, 1.5)
	else:
		camera.rotation.x -= look_dir.y * sens


## Applies joypad input to the player [Camera3D].
func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector(
			"look_left", 
			"look_right", 
			"look_up", 
			"look_down",
	)
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod * camera_zoom_sens)
		look_dir = Vector2.ZERO


func apply_knockback(amount: Vector3, knockup: float = 0) -> void:
	if amount.y > Globals.C_EPSILON or knockup > Globals.C_EPSILON:
		#jump_vel = Vector3.ZERO
		grav_vel = Vector3.UP * knockup
		jumping = false
		slamming = false
	knockback_vel += amount
#	print("knockback applied")


func _toggle_crouch(to: bool) -> void:
	if is_on_floor():
		translate(Vector3(0, -1 if to else 1, 0))
		cam_y_offset += 1 if to else -1
		slide_vel = walk_vel
		stream_player.stream = slide_stream
		stream_player.play()
	crouching = to
	hitbox.disabled = to
	crouchbox.disabled = not to


#region movement functions

## Calculates and returns velocity from player directional input.
func _walk(delta: float) -> Vector3:
	var move_input: Vector2 = Input.get_vector(
			"move_left", 
			"move_right", 
			"move_forward", 
			"move_backwards",
	)
	move_dir = move_dir.move_toward(move_input, delta * acceleration / speed)
	var forward: Vector3 = transform.basis * Vector3(move_input.x, 0, move_input.y)
	var walk_dir := Vector3(forward.x, 0, forward.z).normalized()
	
	if slamming:
		if (
				Input.is_action_just_pressed("jump")
				and move_input.length_squared() > Globals.C_EPSILON
		):
			slamming = false
			slam_decay = 0
			slam_timer = 0
			grav_vel = Vector3.ZERO
			
			slide_vel = walk_dir * speed/4
			stream_player.stream = slide_stream
			stream_player.play()
		else:
			#return Vector3.ZERO
			walk_vel = walk_vel.move_toward(walk_dir * move_dir.length(), acceleration * delta)
	else:
		walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	
	# Roll camera while strafing
	camera.rotation.z = move_toward(
			camera.rotation.z,
			move_dir.x * -roll_intensity,
			delta * roll_speed
	)
	
	if move_dir.length() <= Globals.C_EPSILON:
		sway_timer = PI/2 #smoothstep(sway_timer, PI/2, delta)
	else:
		sway_timer += delta
	# Handle camera & weapon sway/jump lag
	camera.position = Vector3(
			(
					move_dir.length() 
					* sway_height 
					* cos(sway_speed * sway_timer) 
					- move_dir.x 
					* strafe_sway
			),
			(
					0.5 
					+ move_dir.length() 
					* sway_height 
					/ 3 
					* sin(2 * sway_speed * sway_timer)
			),
			0,
	) if is_on_floor() else Vector3(
			0,
			0.5 - clampf((grav_vel.y) * jump_sway, -0.1, 0.1),
			0,
	)
	# Manipulating the offsets like this makes it look like the weapon is
	# moving relative to the camera without having to actually move the weapon
	camera.h_offset = move_dir.x * strafe_sway
	camera.v_offset = (
			move_dir.length() * -sway_height / 6 * sin(10 * sway_timer)
	) if is_on_floor() else clampf(
			(grav_vel.y) * jump_sway,
			-0.1,
			0.1
	)
	return walk_vel


## Calculates and returns velocity from player sliding.
func _slide(delta: float) -> Vector3:
	if is_on_floor() or walk_vel.normalized().dot(slide_vel.normalized()) < 0.5:
		slide_vel = slide_vel.move_toward(Vector3.ZERO, delta * slide_drag)
	return Vector3.ZERO if slamming else slide_vel


## Calculates and returns velocity due to gravity.
func _gravity(delta: float) -> Vector3:
	if slamming:
		slam_timer += delta
		if is_on_floor():
			slamming = false
			slam_decay = 1.0
			var slam_wave := slam_wave_scene.instantiate()
			slam_wave_spawner.add_child(slam_wave)
			slam_wave.reparent(get_tree().current_scene)
			# this feels really dirty but i can't think of a better way to do it
			# that doesn't require sacrificing performance to find_child()
			(slam_wave.get_child(0) as AreaDamage).invoker = self
			(slam_wave.get_child(0).get_child(1) as AreaDamage).invoker = self
			#stream_player.stream = slam_land_stream
			#stream_player.play()
		else:
			grav_vel = Vector3(0, -slam_speed, 0)
	elif jumping:
		if jumps > 0:
			#print(slam_timer)
			grav_vel = (sqrt(4 * jump_height * gravity) + slam_timer * 10) * Vector3.UP #Vector3(0, sqrt(4 * (jump_height) * gravity) + slam_timer * 10, 0)
			jumps -= 1
			slam_decay = 0
			slam_timer = 0
		jumping = false
		reorienting = false
	else:
		if slam_decay <= 0:
			slam_timer = 0.0 #smoothstep(slam_timer, 0.0, delta)
		else:
			slam_decay -= delta
		if is_on_floor():
			grav_vel = Vector3.ZERO
		else:
			grav_vel -= Vector3.UP * (rise_grav if Input.is_action_pressed("jump") else fall_grav) * delta
		#grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(
				#Vector3(0, velocity.y - (
						#rise_grav
						#if Input.is_action_pressed("jump")
						#else fall_grav
				#), 0), (
						#rise_grav
						#if Input.is_action_pressed("jump")
						#else fall_grav
				#) * delta
		#)
	return grav_vel


## Calculates and returns velocity from player jumping.
#func _jump(delta: float) -> Vector3:
		#return jump_vel
	#if is_on_floor():
		#jump_vel = Vector3.ZERO
	#else:
		#jump_vel = jump_vel.move_toward(
				#Vector3(0, sqrt(4 * jump_height * gravity), 0) 
				#if Input.is_action_pressed("jump") 
				#else Vector3.ZERO, (
						#rise_grav
						##if Input.is_action_pressed("jump")
						##else fall_grav
				#) * delta
		#)
	#return jump_vel


## Calculates and returns knockback velocity from impacts.
func _knockback(delta: float) -> Vector3:
	#if is_on_floor():
	knockback_vel = knockback_vel.move_toward(Vector3.ZERO, knockback_drag * delta)
	return knockback_vel


func _fly(delta: float) -> Vector3:
	var move_input: Vector2 = Input.get_vector(
			"move_left", 
			"move_right", 
			"move_forward", 
			"move_backwards",
	)
	#move_dir = move_dir.move_toward(move_input, delta * acceleration / speed)
	var fly_input: float = Input.get_axis("crouch", "jump")
	var forward: Vector3 = camera.global_basis * Vector3(move_input.x, fly_input, move_input.y)
	var walk_dir := forward.normalized()
	grav_vel = Vector3.ZERO
	camera.position = Vector3(0.0, 0.5, 0.0)
	camera.h_offset = 0.0
	camera.v_offset = 0.0
	walk_vel = walk_vel.move_toward(walk_dir * speed, acceleration * delta)
	return walk_vel

#endregion


# TODO implement carriable object logic
## Called when the player picks up a carriable object. Not currently implemented.
func _on_carriable_grabbed(what: Carriable) -> void:
	camera.switched_weapons.emit(-1, -1)
	holding = what


func step_check(vel: Vector3) -> bool:
	#var test_transform := Transform3D(global_transform)
	
	if test_move(global_transform, vel) and not test_move(global_transform, vel + 0.5 * Vector3.UP):
		pass
	
	return false


#region console commands

func add_console_commands() -> void:
	Console.add_command("reset_pos", cmd_reset_pos, [], 0, Globals.parse_text("console", "desc.reset_pos"))
	Console.add_command("tele", cmd_tele, ["x", "y", "z"], 3, Globals.parse_text("console", "desc.tele"))
	Console.add_command("invis", cmd_invis, ["true/false"], 0, Globals.parse_text("console", "desc.invis"))
	Console.add_command("noclip", cmd_noclip, ["true/false"], 0, Globals.parse_text("console", "desc.noclip"))


func remove_console_commands() -> void:
	Console.remove_command("reset_pos")
	Console.remove_command("tele")
	Console.remove_command("invis")
	Console.remove_command("noclip")


func cmd_reset_pos() -> void:
	if Globals.try_run_cheat():
		position = Vector3.ZERO


func cmd_tele(x: String, y: String, z: String) -> void:
	if Globals.try_run_cheat():
		var to: Vector3
		
		if x.begins_with("~") and x.substr(1).is_valid_float():
			to.x = global_position.x + x.substr(1).to_float()
		elif x.is_valid_float():
			to.x = x.to_float()
		else:
			Console.print_error(Globals.parse_text("console", "fail.bad_float") % x)
			return
		
		if y.begins_with("~") and x.substr(1).is_valid_float():
			to.y = global_position.x + x.substr(1).to_float()
		elif y.is_valid_float():
			to.y = y.to_float()
		else:
			Console.print_error(Globals.parse_text("console", "fail.bad_float") % y)
			return
		
		if z.begins_with("~") and z.substr(1).is_valid_float():
			to.z = global_position.z + z.substr(1).to_float()
		elif z.is_valid_float():
			to.x = z.to_float()
		else:
			Console.print_error(Globals.parse_text("console", "fail.bad_float") % z)
			return
		
		global_position = to #Vector3(
				#global_position.x if x == "~" else x.to_float(), 
				#global_position.y if y == "~" else y.to_float(), 
				#global_position.z if z == "~" else z.to_float(),
		#)


func cmd_invis(to: String) -> void:
	if Globals.try_run_cheat():
		if to == "":
			EnemyBase.player_hidden = not EnemyBase.player_hidden
		else:
			var to_b := Globals.get_pseudo_bool(to)
			if to_b == -1:
				Console.print_error(Globals.parse_text("console", "fail.bad_bool") % to)
			else:
				EnemyBase.player_hidden = to_b == Globals.PseudoBool.TRUE
			Console.print_line(Globals.parse_text("console", "invis") % ("on" if EnemyBase.player_hidden else "off"))


func cmd_noclip(to: String) -> void:
	if Globals.try_run_cheat():
		if to == "":
			noclip = not noclip
		else:
			var to_b := Globals.get_pseudo_bool(to)
			if to_b == -1:
				Console.print_error(Globals.parse_text("console", "fail.bad_bool") % to)
			else:
				noclip = to_b == Globals.PseudoBool.TRUE
		if noclip:
			hitbox.disabled = true
			crouchbox.disabled = true
		else:
			hitbox.disabled = false
		Console.print_line(Globals.parse_text("console", "noclip") % ("on" if noclip else "off"))

#endregion
