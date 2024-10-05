extends Control


enum TallyPhase {
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


@onready var time_label := find_child("Label") as Label
@onready var kills_label := find_child("Label2") as Label
@onready var secrets_label := find_child("Label3") as Label


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	visible = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tally_skip :=  Input.is_anything_pressed() and not tally_lock
	if Input.is_anything_pressed():
		tally_lock = true
	elif tally_lock:
		tally_lock = false
	match tally_phase:
		TallyPhase.TIME:
			time_tally = lerpf(time_tally, _time, delta * 60)
			time_label.text = "{text}: {hr}:{min}:{sec}".format({
					"text": Globals.parse_text("ui", "intermission.time_label"),
					"hr": "%02d" % (time_tally / 3600.0), # process hours
					"min": "%02d" % (time_tally / 60.0), # process minutes
					"sec": "%02.3f" % time_tally, # process seconds/milliseconds
			})
			if is_equal_approx(time_tally, _time) or tally_skip:
				tally_phase = TallyPhase.KILLS
		TallyPhase.KILLS:
			foes_tally = Globals.intstep(foes_tally, _foes)
			kills_tally = Globals.intstep(kills_tally, _kills)
			time_label.text = "{text}: {kills}/{foes}".format({
					"text": Globals.parse_text("ui", "intermission.kills_label"),
					"kills":  "%0*d" % [ceili(log(_foes)) / log(10), kills_tally],
					"foes": "%0*d" % [ceili(log(_foes)) / log(10), foes_tally],
			})
			if (foes_tally == _foes and kills_tally == _kills) or tally_skip:
				tally_phase = TallyPhase.SECRETS
		TallyPhase.SECRETS:
			secrets_tally = Globals.intstep(secrets_tally, _secrets)
			found_secrets_tally = Globals.intstep(found_secrets_tally, _found_secrets)
			time_label.text = "{text}: {found}/{secrets}".format({
					"text": Globals.parse_text("ui", "intermission.secrets_label"),
					"found":  "%0*d" % [ceili(log(_secrets)) / log(10), found_secrets_tally],
					"secrets": "%0*d" % [ceili(log(_secrets)) / log(10), secrets_tally],
			})
			if (secrets_tally == _secrets and found_secrets_tally == _found_secrets) or tally_skip:
				tally_phase = TallyPhase.DONE
		TallyPhase.DONE:
			if tally_skip:
				Globals.open_level_from_key(_next_level)


func run_intermission(player: Player, time: float, foes: int, kills: int, secrets: int, found_secrets: int, next_level: String) -> void:
	player.process_mode = PROCESS_MODE_DISABLED
	player.get_parent().remove_child(player)
	
	_time = time
	_foes = foes
	_kills = kills
	_secrets = secrets
	_found_secrets = found_secrets
	_next_level = next_level
	
	time_tally = 0.0
	foes_tally = 0
	kills_tally = 0
	secrets_tally = 0
	found_secrets_tally = 0
	tally_phase = TallyPhase.TIME
	
	visible = true
	process_mode = PROCESS_MODE_PAUSABLE
