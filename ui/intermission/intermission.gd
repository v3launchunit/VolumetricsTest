extends Node


@export var intermission_screen: PackedScene

var _time: float = 0.0
var _foes: int = 0 ## total number of tallied foes in the level.
var _kills: int = 0
var _secrets: int = 0 ## total number of secrets in the level.
var _found_secrets: int = 0
var _next_level: String = "e1m3"
var screenshot: Image


func run_intermission(player: Player, time: float, foes: int, kills: int, secrets: int, found_secrets: int, next_level: String) -> void:
	#player.process_mode = PROCESS_MODE_DISABLED
	#player.get_parent().remove_child(player)
	
	_time = time
	_foes = foes
	_kills = kills
	_secrets = secrets
	_found_secrets = found_secrets
	_next_level = next_level
	
	await RenderingServer.frame_post_draw
	screenshot = (player.find_child("SubViewport") as SubViewport).get_texture().get_image()
	
	ResourceLoader.load_threaded_request(Globals.get_level_path(next_level))
	get_tree().change_scene_to_packed(intermission_screen)
