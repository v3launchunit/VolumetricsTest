class_name AttackPattern extends Resource

@export_range(0.0, 100.0, 0.001) var weight: float = 1.0

@export_group("Projectiles")
@export var bullet: PackedScene
@export_range(1, 10, 1, "or_greater") var volley: int = 1
@export_range(0.0, 180.0, 0.1, "degrees") var spread: float = 0.0
@export var spawners: Array[NodePath] #= ["Spawner"]
@export_subgroup("Nightmare")
@export var nightmare_bullet: PackedScene

@export_group("Behaviors")
@export_range(0.0, 10.0, 0.01, "or_greater") var delay: float = 0.5
@export_range(0.0, 10.0, 0.01, "or_greater") var recovery_time: float = 0.25
@export var animation: StringName = "attacking"
@export_range(1, 10, 1, "or_greater") var burst: int = 1
@export_range(0.0, 1.0, 0.01, "or_greater") var burst_delay: float = 0.1
@export var cancelable: bool = false
