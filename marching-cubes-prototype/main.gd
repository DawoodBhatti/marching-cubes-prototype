extends Node

func _ready() -> void:

	#print all nodes in scene
	print()
	print_all_nodes(get_tree().root)
	print()

	#place sphere at global origin
	spawn_debug_sphere()


