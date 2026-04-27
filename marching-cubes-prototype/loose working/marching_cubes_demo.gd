extends Node3D

@export var chunk_size: int = 1
@export var iso_level: float = 0.0
@export var radius: float = 5.0


func _ready():
	var chunk = $Chunk
	print(chunk.global_position)
	chunk.global_position = Vector3(0,0,0)
	
	chunk.generate(chunk_size, iso_level, radius)
