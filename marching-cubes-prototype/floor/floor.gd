extends Node3D

@onready var mesh_instance: MeshInstance3D = $Mesh3D
@onready var static_body: StaticBody3D = $StaticBody3D
@onready var collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D

#horizontal dimensions
@export var floor_width: float = 40.0
@export var floor_depth: float = 40.0

#vertical dimensions
@export var floor_height: float = 0.0

# Load the material relative to this folder
@onready var pattern_material: ShaderMaterial = preload("res://floor/materials/pattern_chessboard.tres")

func _ready() -> void:
	_setup_mesh()
	_setup_collision()
	
	

func _setup_mesh() -> void:
	var box := BoxMesh.new()
	box.size = Vector3(floor_width, floor_height, floor_depth)
	mesh_instance.mesh = box
	mesh_instance.material_override = pattern_material
	
	#move center to global 0
	#mesh_instance.position = -box.size/2

	
func _setup_collision() -> void:
	var box := BoxShape3D.new()
	box.size = Vector3(floor_width, floor_height, floor_depth)
	collision_shape.shape = box

	static_body.collision_layer = 1
	static_body.collision_mask = 1
