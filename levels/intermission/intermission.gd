extends Node


@export var intermission_screen: PackedScene

## the amount of time spent inside the level, in seconds.
var _time : float = 0.0
## the total number of tallied foes in the level.
var _foes : int = 0 
## the number of tallied foes killed by the player in the level.
var _kills : int = 0
## the total number of secrets in the level.
var _secrets : int = 0 
## the number of secrets that the player managed to find within the level.
var _found_secrets : int = 0
## the level to load after the intermission.
var _next_level : String = "e1m1"
var screenshot : Image

var carry_status : bool = false
var player_health : float = 100.0
var player_armor : float = 25.0
var player_ammo : Dictionary[String, int] = {
	"shells": 15,
	"grenades": 3,
}


func run_intermission(player: Player, time: float, foes: int, kills: int, secrets: int, found_secrets: int, next_level: String) -> void:
	#player.process_mode = PROCESS_MODE_DISABLED
	#player.get_parent().remove_child(player)
	
	_time = time
	_foes = foes
	_kills = kills
	_secrets = secrets
	_found_secrets = found_secrets
	_next_level = next_level
	
	player_health = player.status.health
	player_armor = player.status.armor
	player_ammo = player.camera.ammo_amounts.duplicate()
	
	await RenderingServer.frame_post_draw
	screenshot = (player.find_child("SubViewport") as SubViewport).get_texture().get_image()
	
	ResourceLoader.load_threaded_request(Globals.get_level_path(next_level))
	get_tree().change_scene_to_packed(intermission_screen)
