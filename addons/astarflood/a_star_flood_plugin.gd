@tool
class_name AStarFloodPlugin
extends EditorPlugin


const AStarFlood3DGizmo = preload("res://addons/astarflood/a_star_flood_3d_gizmo_plugin.gd")

var gizmo := AStarFlood3DGizmo.new()


func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(gizmo)


func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo)
