extends Control


enum TallyPhase {
	MELT,
	TIME,
	KILLS,
	SECRETS,
	DONE,
}


var _time: float = 0.0
var _foes: int = 0 ## total number of tallied foes in the level.
var _kills: int = 0
var _secrets: int = 0 ## total number of secrets in the level.
var _found_secrets: int = 0
var _next_level: String

var time_tally: float = 0.0
var foes_tally: int = 0
var kills_tally: int = 0
var secrets_tally: int = 0
var found_secrets_tally: int = 0

var tally_phase := TallyPhase.TIME

var tally_lock: bool = false

var screenshot: Image


@onready var time_label := find_child("TimeLabel") as Label
@onready var kills_label := find_child("KillsLabel") as Label
@onready var secrets_label := find_child("SecretsLabel") as Label
@onready var stream_player := $AudioStreamPlayer3D as AudioStreamPlayer
@onready var screenshot_rect := $TextureRect as TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_language_changed()
	
	_time = Intermission._time
	_foes = Intermission._foes
	_kills = Intermission._kills
	_secrets = Intermission._secrets
	_found_secrets = Intermission._found_secrets
	_next_level = Intermission._next_level
	
	time_tally = 0.0
	foes_tally = 0
	kills_tally = 0
	secrets_tally = 0
	found_secrets_tally = 0
	tally_phase = TallyPhase.TIME
	
	screenshot = Intermission.screenshot
	screenshot_rect.texture = ImageTexture.create_from_image(screenshot)
	
	Globals.language_changed.connect(_on_language_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	print(tally_phase)
	match tally_phase:
		TallyPhase.TIME:
			time_tally = lerpf(time_tally, _time, delta * 60)
			time_label.text = "{hr}:{min}:{sec}".format({
					"hr": "%02d" % (time_tally / 3600.0), # process hours
					"min": "%02d" % (time_tally / 60.0), # process minutes
					"sec": "%02.3f" % time_tally, # process seconds/milliseconds
			})
			if abs(time_tally - _time) < 0.001 or Globals.menu_click():
				tally_phase = TallyPhase.KILLS
				stream_player.play()
		TallyPhase.KILLS:
			foes_tally = Globals.intstep(foes_tally, _foes)
			kills_tally = Globals.intstep(kills_tally, _kills)
			kills_label.text = "{kills}/{foes}".format({
					"kills":  "%0*d" % [mini(ceili(log(_foes)) / log(10), 1), kills_tally],
					"foes": "%0*d" % [mini(ceili(log(_foes)) / log(10), 1), foes_tally],
			})
			if (
					(foes_tally == _foes and kills_tally == _kills) 
					or Input.is_action_just_pressed("weapon_fire_main")
			):
				tally_phase = TallyPhase.SECRETS
				stream_player.play()
		TallyPhase.SECRETS:
			secrets_tally = Globals.intstep(secrets_tally, _secrets)
			found_secrets_tally = Globals.intstep(found_secrets_tally, _found_secrets)
			secrets_label.text = "{found}/{secrets}".format({
					"found":  "%0*d" % [mini(ceili(log(_secrets)) / log(10), 1), found_secrets_tally],
					"secrets": "%0*d" % [mini(ceili(log(_secrets)) / log(10), 1), secrets_tally],
			})
			if (
					(secrets_tally == _secrets and found_secrets_tally == _found_secrets) 
					or Input.is_action_just_pressed("weapon_fire_main")
			):
				tally_phase = TallyPhase.DONE
				stream_player.play()
		TallyPhase.DONE:
			if Input.is_action_just_pressed("weapon_fire_main"):
				Globals.open_level_from_key(_next_level)


func _on_language_changed() -> void:
	($Labels/TimeLabel as Label).text = "%s:" + Globals.parse_text("ui", "intermission.time_label")
	($Labels/KillsLabel as Label).text = "%s:" + Globals.parse_text("ui", "intermission.kills_label")
	($Labels/SecretsLabel as Label).text = "%s:" + Globals.parse_text("ui", "intermission.secrets_label")
