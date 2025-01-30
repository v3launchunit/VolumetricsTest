@tool

class_name AreaHazard
extends Area3D

enum HazardType {
	DEATH_BARRIER,
	LAVA,
	CUSTOM = -1,
}

## The layermask used during normal behavior.
const DEFAULT_LAYERS : int = 0b0000_0000_0000_0000_0000_0000_0000_0001

## The layermask used while placing decoration props.
const PROP_SPAWN_LAYERS : int = 0b1000_0000_0000_0000_0000_0000_0000_0000

#static var hazard_types: Array[HazardType] = [
	#HazardType.new(10_000_000, 10_000_000, Status.DamageType.ABSOLUTE), # death barrier
	#HazardType.new(10_000_000, 10_000_000, Status.DamageType.FIRE), # lava
#]

@export var func_godot_properties: Dictionary:
	set(to):
		if to != func_godot_properties:
			func_godot_properties = to
			if to.get("decorate", false):
				decorate_hazard()

@export var dps: float = 1.0
@export var player_dps_override: float = 1.0
@export var damage_type: Status.DamageType = Status.DamageType.GENERIC
@export var hazard_type := HazardType.CUSTOM

#@export_storage var hazard_type: HazardType


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if func_godot_properties:
		if func_godot_properties.get("hazard_type", -1) != -1:
			hazard_type = func_godot_properties["hazard_type"]
			match hazard_type:
				HazardType.DEATH_BARRIER:
					dps = 10_000_000
					player_dps_override = 10_000_000
					damage_type = Status.DamageType.ABSOLUTE
				HazardType.LAVA:
					dps = 20
					player_dps_override = 20
					damage_type = Status.DamageType.FIRE
		else:
			dps = func_godot_properties["dps"]
			player_dps_override = func_godot_properties["player_dps"]
			damage_type = Status.DamageType[func_godot_properties["damage_type"]]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	for body in get_overlapping_bodies():
		if body.has_node("Status"):
			body.get_node("Status").rapid_damage_typed(dps, damage_type, delta)


func decorate_hazard() -> void:
	return
	#await tree_entered
	#if not Engine.is_editor_hint():
		#return
	#match func_godot_properties.get("hazard_type", -1):
		#HazardType.LAVA:
			#var bounds := AABB(Vector3.ZERO, Vector3.ZERO)
			#for m in get_children():
				#if m is not MeshInstance3D:
					#continue
				#bounds = bounds.merge((m as MeshInstance3D).mesh.get_aabb())
			#var fog := FogVolume.new()
			#fog.material = preload("res://objects/deco/hazards/lava_fog.tres")
			#fog.size = bounds.size - 0.1 * Vector3.UP
			#add_child(fog)
			#fog.set_owner(get_tree().edited_scene_root)
			#fog.position = bounds.get_center()
			#return
		#_:
			#return
	
	#for m in get_children():
		#if m is not MeshInstance3D:
			#continue
		#var mesh := (m as MeshInstance3D).mesh
		#var shape := mesh.create_convex_shape(false)
		#var bounds := mesh.get_aabb().abs()
		#var volume : float = bounds.get_volume()
		#
		#var point_query := PhysicsPointQueryParameters3D.new()
		#point_query.collide_with_bodies = false
		#point_query.collide_with_areas = true
		#point_query.collision_mask = PROP_SPAWN_LAYERS
		#
		#var x = bounds.position.x
		#var y = bounds.position.y


#class HazardType:
	#var _dps: float = 5.0
	#var _player_dps: float = 5.0
	#var _damage_type := Status.DamageType.GENERIC
	#var _area_deco: Node3D = null
	#var _area_deco_spacing: float = 4.0
#
	#func _init(dps, player_dps = dps, damage_type = Status.DamageType.GENERIC, area_deco = null, area_deco_spacing = 4.0) -> void:
		#_dps = dps
		#_player_dps = player_dps
		#_damage_type = damage_type
		#_area_deco = area_deco
		#_area_deco_spacing = area_deco_spacing
