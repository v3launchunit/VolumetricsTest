extends StaticBody3D


@export var func_godot_properties: Dictionary

@export_storage var status: Status


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if status == null:
		status = Status.new()
		status.max_health = func_godot_properties["max_health"]
		status.gib_threshold = func_godot_properties["gib_threshold"]
		status.base_damage_factor = func_godot_properties["base_damage_factor"]
		status.burn_prone = func_godot_properties["burn_prone"]
		status.burn_rate = func_godot_properties["burn_rate"]
		
		if func_godot_properties.has("damage_sys") and func_godot_properties["damage_sys"] != "":
			status.damage_sys = load(Globals.parse_names("Effects", func_godot_properties["damage_sys"]))
			
		if func_godot_properties.has("gibs") and func_godot_properties["gibs"] != "":
			status.gibs = load(Globals.parse_names("Effects", func_godot_properties["gibs"]))
			
		status.damage_multipliers = func_godot_properties["damage_multipliers"].split_floats(" ", false)
		
		add_child(status)
		await get_tree().process_frame # make sure owner has had time to initialize
		status.owner = owner


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
