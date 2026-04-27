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


#spawn multimesh of spheres
#using an input array of coordinates, sphere mesh and optional colour
func spawn_debug_multimesh(positions : PackedVector3Array, base_mesh : SphereMesh, base_colour: Color = Color(0.673, 0.309, 0.745, 1.0)):
	

	var mmesh3d : MultiMeshInstance3D =  MultiMeshInstance3D.new()
	var mmesh : MultiMesh =  MultiMesh.new()
	var colour_array : PackedColorArray = PackedColorArray()
	var count = positions.size()
	
	mmesh3d.multimesh=mmesh
	mmesh.transform_format = MultiMesh.TRANSFORM_3D
	mmesh.use_colors = true
	mmesh.instance_count = count
	mmesh.mesh = base_mesh
	
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mmesh3d.material_override = mat

	for i in range(count):
		colour_array.append(base_colour)
	
	mmesh.color_array=colour_array

	#add 3d manager to scene
	add_child(mmesh3d)

	var translations = Transform3D()
	
	for i in range (0,count):
		var offset = positions[i]
		print("offset: ", offset)
		mmesh.set_instance_transform(i, translations.translated(offset))



#spawns a single debug sphere and returns the SphereMesh instance
func spawn_debug_sphere(
		position: Vector3 = Vector3.ZERO,
		radius: float = 0.1,
		color: Color = Color(1, 0, 0, 1)
	) -> SphereMesh:

	var sphere_m3d := MeshInstance3D.new()
	var mesh := SphereMesh.new()

	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 32
	mesh.rings = 16

	sphere_m3d.mesh = mesh

	# Simple unshaded material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere_m3d.set_surface_override_material(0, mat)

	# Add to the scene FIRST
	add_child(sphere_m3d)

	# Now it's safe to set global transform
	sphere_m3d.global_transform = Transform3D(Basis(), position)

	return mesh


#overspawning spheres
#underspawning shape...
func visualise_SDF_sphere(debug_color : Color):
	
	print("visualising sphere...\n")
	
	var size : float = 1.0
	var step: float = 0.5
	var half : float = size / 2.0
	var x : float = -half - step
	var y: float = -half - step 
	var z: float = -half
	var p : Vector3
	var sample : float
	var positions : PackedVector3Array = PackedVector3Array()

	while x <= half :
		x += step
		y= -half   # RESET y each x-iteration
		while y <= half:
			y += step
			z= -half   # RESET z each y-iteration
			while z <=half :
			   
				p=Vector3(x, y, z)
				sample = sphere.sample(p)
				positions.append(p)
				
				#print("x, y, z: ", x , ", ", y , ", ", z)
				#print("sample val: ", sample)
				#print()
				z += step
				
		spawn_debug_multimesh(positions,spawn_debug_sphere())



func visualise_SDF_cube(debug_color : Color):
	
	print("visualising cube...")
	
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
