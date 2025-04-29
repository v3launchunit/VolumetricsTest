extends Label

@onready var level := get_tree().current_scene as Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if level != null:
		text = "{name}\n{hr}:{min}:{sec}\n{phr}:{pmin}:{psec}\n{kills}/{foes}\n{found}/{secrets}\n{scoreb},{scorem},{scorek},{score}".format({
				"name": level.level_name, # name
				"hr": "%02d" % (level.time / 3600.0), # process hours
				"min": "%02d" % (level.time / 60.0), # process minutes
				"sec": "%02.3f" % level.time, # process seconds/milliseconds
				"phr": "%02d" % (level.physics_time / 3600.0), # physics hours
				"pmin": "%02d" % (level.physics_time / 60.0), # physics minutes
				"psec": "%02.3f" % level.physics_time, # physics seconds/milliseconds
				"kills": "%0*d" % [ceili(log(level.foes)) / log(10), level.kills], # enemies killed
				"foes": "%s" % level.foes, # total enemies
				"found": "%03d" % [ceili(log(level.secrets)) / log(10), level.found_secrets], # secrets found
				"secrets": "%03d" % level.secrets, # total number of secrets
				"scoreb": "%03d" % ((level.score / 100_000_000) % 1000), # total score, first 3 digits
				"scorem": "%03d" % ((level.score / 100_000) % 1000), # total score, next 3 digits
				"scorek": "%03d" % ((level.score / 100) % 1000), # total score, following 3 digits
				"score": "%02d0" % (level.score % 100), # total score, last 2 digits + bonus 0
		})
	else:
		level = get_tree().current_scene as Level
	if Input.is_action_just_pressed("hud_toggle_stats"):
		visible = not visible
