extends Area3D

@export var properties: Dictionary = {}

@onready var link := find_child("NavigationLink3D") as NavigationLink3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	link.end_position = to_local(Globals.C_LIZARD_HOLE_POINT)
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if body is EnemyLizard:
		(body as EnemyLizard).escape()
