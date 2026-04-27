extends Node

@onready var sphere : SDF = SDFSphere.new()
@onready var cube : SDF = SDFCube.new()


func print_all_nodes(node: Node) -> void:
	# Only nodes with transforms have positions
	if node is Node3D:
		print("%s — %s" % [node.name, node.global_transform.origin])
	elif node is Node2D:
		print("%s — %s" % [node.name, node.global_position])

	# Recurse into children
	for child in node.get_children():
		print_all_nodes(child)


func spawn_debug_sphere(
		position: Vector3 = Vector3.ZERO,
		radius: float = 0.1,
		color: Color = Color(1, 0, 0, 1)
	) -> MeshInstance3D:

	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()

	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 32
	mesh.rings = 16

	sphere.mesh = mesh

	# Simple unshaded material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere.set_surface_override_material(0, mat)

	# Add to the scene FIRST
	add_child(sphere)

	# Now it's safe to set global transform
	sphere.global_transform = Transform3D(Basis(), position)

	return sphere


func visualise_SDF_sphere(debug_color : Color):
	
	var size : float = 15.0
	var step: float = 0.5
	var half : float = size / 2.0
	var x : float = -half - step
	var y: float = -half - step 
	var z: float = -half
	var p : Vector3
	var sample : float
	
	while x <= half :
		x += step
		y= -half   # RESET y each x-iteration
		while y <= half:
			y += step
			z= -half   # RESET z each y-iteration
			while z <=half :
			   
				p=Vector3(x, y, z)
				sample = sphere.sample(p)
				
				#print("x, y, z: ", x , ", ", y , ", ", z)
				#print("sample val: ", sample)
				#print()
				if sample < 1.0:
					spawn_debug_sphere(p, 0.1, debug_color)

				z += step


func visualise_SDF_cube(debug_color : Color):
	
	var size : float = 10.0
	var step: float = 0.5
	var half : float = size / 2.0
	var x : float = -half - step
	var y: float = -half - step 
	var z: float = -half
	var p : Vector3
	var sample : float

	while x <= half :
		x += step
		y= -half   # RESET y each x-iteration
		
		while y <= half:
			y += step
			z= -half   # RESET z each y-iteration

			while z <=half :
				p=Vector3(x, y, z)
				sample = cube.sample(p)
				
				#print("x, y, z: ", x , ", ", y , ", ", z)
				#print("sample val: ", sample)
				#print()
				if sample < 1.0:
					spawn_debug_sphere(p, 0.1, debug_color)
				z += step
