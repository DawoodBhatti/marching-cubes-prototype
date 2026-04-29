extends Node

@onready var debug : Node = $Debug

func _ready() -> void:

	#print all nodes in scene
	print()
	debug.print_all_nodes(get_tree().root)
	print()

	#place sphere at global origin
	var sphere_mesh = debug.spawn_debug_sphere()
	

	#SDF debug
	#debug.visualise_SDF_sphere(Color(0.876, 0.361, 0.207, 1.0))
	debug.visualise_SDF_cube(Color(0.047, 0.498, 0.667, 1.0))
