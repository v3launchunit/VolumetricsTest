extends GPUParticles3D

var timer: float = 0 # seconds

# Called when the node enters the scene tree for the first time.
func _ready():
#	emitting = true
	timer = 0
	restart()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer >= lifetime:
		queue_free()
