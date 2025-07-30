class_name TrashList
extends Resource

@export var base_lists: Array[TrashList]
@export var props: Array[TrashProp]

func get_prop() -> PackedScene:
	return get_pool().pick_random()

func get_pool() -> Array[PackedScene]:
	var pool : Array[PackedScene]
	
	for list: TrashList in base_lists:
		pool.append_array(list.get_pool())
	
	for prop: TrashProp in props:
		for i in range(floori(prop.weight)):
			pool.append(prop.scene)
		if randi() > prop.weight - floorf(prop.weight):
			pool.append(prop.scene)
	
	print(pool)
	return pool
