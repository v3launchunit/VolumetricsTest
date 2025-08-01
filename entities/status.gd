class_name Status 
extends Node


## Emitted whenever this node takes damage.
signal injured(source: Node3D)
## Emitted when this node dies.
signal died

enum DamageType {
	## Generic damage cause.
	GENERIC,
	## Damage type used by explosions.
	EXPLOSION,
	## Damage type used by "fire" weapons/hazards, such as flamethrowers or 
	## lava pits. Ignites certain enemies and objects, causing damage over time.
	FIRE,
	## Damage type used by "toxic" weapons/hazards, such as pollution. 
	## Cannot gib enemies or apply post-mortem damage.
	TOXIC,
	## Damage type used by "electric" weapons, such as the Crossbow.
	ELECTRIC,
	## Damage type from being hit by a thrown physics object.
	IMPACT,
	## "Absolute" damage type. Ignores resistances and vulnerabilities.
	ABSOLUTE = -1,
}

enum GibMode {
	BLOCK_GIB,
	ALLOW_GIB,
	FORCE_GIB,
}


## The amount of health this node will have when initialized, and the maximum
## amount of health it can be healed to (besides bonus health).
@export var max_health: float = 100.0
## The amount of additional damage after death required to cause this node's
## parent to explode into its gibs (if applicable).
@export var gib_threshold: float = 50.0
## Generic multiplier applied to all incoming damage.
@export var base_damage_factor: float = 1.0
@export var damage_multipliers: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
@export var armor_class: ArmorClass = preload("res://entities/armor_generic.tres")
## If set to true, any attack will ignite this node.
@export var burn_prone: bool = false 
## How much damage this node should take per second of being on fire. 
@export var burn_rate: float = 4.0
## The [GPUParticles3D] that will activate when this node is set ablaze. If null,
## this node will be immune to being set on fire.
@export var burn_sys: GPUParticles3D
## The scene that instantiates whenever this node takes damage.
@export var damage_sys: PackedScene
## The scene that instantiates if this node's parent is reduced to gibs.
@export var gibs: PackedScene
## The position offset to apply when spawning [member gibs].
@export var gibs_offset: Vector3 = Vector3.ZERO
## One of the contained scenes will be randomly selected to be instantiated
## when this node's parent dies.
@export var loot: Array[PackedScene] = []
## How far up the tree this node should affect its parents.
@export var ripple_distance: int = 1

@export_group("Scoring")
## Whether this node should be considered by the kill counter.
@export var is_enemy: bool = false
## How many points should be awarded upon the death of this node.
@export_range(0, 10, 1, "or_greater", "or_less") var score: int = 0

#@export_group("Save Data")
## This node's current health.
@export_storage var health: float
## Whether this node is currently dead.
@export_storage var is_dead: bool = false
## Which node to free when reduced to gibs.
@export_storage var target_parent: Node
## Whether this node is currently "on fire".
@export_storage var burning: bool = false:
	set(to):
		if burn_sys != null and burning != to:
			burning = to
			burn_sys.emitting = to
			burn_sys.visible = to
			burn_sys.restart(true)
#var overheal_decay_rate: float = 1 # hp/second

#@onready var gibs_scene: PackedScene = load(gibs)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	target_parent = get_parent()
	for i in (ripple_distance - 1):
		target_parent = target_parent.get_parent()
#	if get_parent().has_signal("body_entered"):
#		get_parent().body_entered.connect(damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if burning:
		rapid_damage_typed(burn_rate, DamageType.FIRE, delta, GibMode.FORCE_GIB)
#	if health > max_health:
#		health -= overheal_decay_rate * delta
#		if health < max_health:
#			health = max_health


## tbh i don't have any idea why i made this a separate function instead of just 
## having damage type default to generic.
func damage(amount: float, gib_mode: GibMode = GibMode.ALLOW_GIB) -> float:
	return damage_typed(amount, DamageType.GENERIC, gib_mode)


## Applies damage to this node. 
## Returns the amount of damage actually recieved, for piercers.
func damage_typed(amount: float, type: DamageType, gib_mode: GibMode = GibMode.ALLOW_GIB) -> float:
	if is_dead and (type == DamageType.TOXIC or gib_mode == GibMode.BLOCK_GIB):
		return 0 # toxic clouds shouldn't gib
	health -= amount * base_damage_factor * (armor_class.damage_multipliers.get(type, 1.0) if type != DamageType.ABSOLUTE else 1.0)
	if type == DamageType.FIRE or burn_prone:
		burning = true
#	print(health)
	if damage_sys != null:
		var instance := damage_sys.instantiate()
		target_parent.add_child(instance)
	if health <= -gib_threshold and gib_mode != GibMode.BLOCK_GIB:
		gibify()
		return 0
	if is_dead:
		return 0 # corpses cannot stop piercers
	if health <= 0:
		kill()
		if gib_mode == GibMode.FORCE_GIB:
			gibify()
		return maxf(amount + health, 0) # health will be negative
	injured.emit()

	return amount # return value is amount of damage recieved, for piercers


func rapid_damage(amount: float, delta: float, gib_mode: GibMode = GibMode.ALLOW_GIB) -> void:
	rapid_damage_typed(amount, DamageType.GENERIC, delta, gib_mode)


## Special damage function for hazards (e.g. lava, toxic clouds, etc).
func rapid_damage_typed(amount: float, type: DamageType, delta: float, gib_mode: GibMode = GibMode.ALLOW_GIB) -> void:
	if is_dead and (type == DamageType.TOXIC or gib_mode == GibMode.BLOCK_GIB):
		return # toxic clouds shouldn't gib
	health -= amount * delta * base_damage_factor * (armor_class.damage_multipliers.get(type, 1.0) if type != DamageType.ABSOLUTE else 1.0)
#	print(health)
	#if damage_sys != null:
		#var instance := damage_sys.instantiate()
		#target_parent.add_child(instance)
	if health <= -gib_threshold and gib_mode != GibMode.BLOCK_GIB:
		gibify()
		return
	if is_dead:
		return
	if health <= 0:
		kill()
		if gib_mode == GibMode.FORCE_GIB:
			gibify()
		return
	injured.emit()


## Attempts to heal this node. Returns whether or not the healing was applied 
## (healing will fail if [member health] is already at or above [member max_health], 
##  and [param can_overheal] is not [code]true[/code]).
func heal(amount: float, can_overheal: bool = false, heal_armor: bool = false) -> bool:
	if not heal_armor and (health < max_health or can_overheal):
		health += amount
		return true
	return false


func telefrag() -> bool:
	kill()
	return true


func kill():
	is_dead = true
	died.emit()
	var l := get_tree().current_scene as Level
	if l:
		l.score += score
		if is_enemy:
			l.kills += 1
	if not loot.is_empty():
		var loot_spawn := (loot.pick_random() as PackedScene).instantiate() as RigidBody3D
		target_parent.add_child(loot_spawn)
		loot_spawn.reparent(get_tree().current_scene)
		loot_spawn.rotation = Vector3(0, 0, 0)
		loot_spawn.linear_velocity = Vector3(randf_range(-3, 3), 10, randf_range(-3, 3))


func gibify():
	if not is_dead:
		kill()
	target_parent.queue_free()
	var i: Node3D
	if gibs != null:
		#print("gibbed")
		i = gibs.instantiate() as Node3D
		target_parent.add_child(i)
		i.translate(gibs_offset)
		i.reparent(get_tree().current_scene)
		gibs = null
	
