@tool
extends EditorPlugin


func _enter_tree():
	pass
	#print("Console plugin activated.")
	#add_autoload_singleton("Console", "res://addons/console/console.gd")


func _exit_tree():
	pass
	#remove_autoload_singleton("Console")
