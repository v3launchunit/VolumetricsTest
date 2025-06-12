class_name Level
extends Node3D


enum OutOfBoundsBehavior {
	KILL, ## Kills the player instantly.
	WRAP, ## Wraps the player back above the level.
	RESET, ## Teleports the player to the origin.
}


## identifier key for this level.
@export var level_key: String = "e1m1"
## name for this level.
@export var level_name: String = "LEVEL"
#@export var level_bounds := AABB(-1024 * Vector3.ONE, 1024 * Vector3.ONE)
#@export var min_height : float = -1024
## what to do if the player falls past [member Globals.C_PLAYER_MIN_HEIGHT]. 
@export var bounds_behavior := OutOfBoundsBehavior.WRAP

#@export_group("Save Data")
## The game version that the level was last saved on, for migration purposes.
@export_storage var level_version: String = "PENDING"
## The total amount of time that the player has spent in the level, tallied during [method _process].
@export_storage var time: float = 0.0
## The total amount of time that the player has spent in the level, tallied during [method _physics_process].
@export_storage var physics_time: float = 0.0
## The number of enemies that the player has killed.
@export_storage var kills: int = 0
## The total number of tallied foes in the level.
@export_storage var foes: int = 0 
## The number of secrets that the player has found.
@export_storage var found_secrets: int = 0
## The total number of secrets in the level.
@export_storage var secrets: int = 0 
## The total accumulated score for this level.
@export_storage var score: int = 0
## Whether this level was loaded from a save file or not.
@export_storage var loaded_from_savegame: bool = false
## The [member fun] value that this level was initially loaded with.
@export_storage var fun: int = -1

func _init() -> void:
	if fun == -1:
		fun = Globals.fun


func _ready() -> void:
	if level_version == "PENDING":
		level_version = Globals.C_VERSION


func _process(delta: float) -> void:
	time += delta


func _physics_process(delta: float) -> void:
	physics_time += delta
