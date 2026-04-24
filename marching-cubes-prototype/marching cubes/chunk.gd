extends Node3D

# Lazy-loaded tables resource
var MC := preload("res://marching cubes/marching_cubes_tables.gd").new()

# Reusable buffers (avoid allocations)
var edge_vertex := PackedVector3Array()
var edge_normal := PackedVector3Array()

# Output buffers
var vertices: PackedVector3Array = []
var normals: PackedVector3Array = []
var indices: PackedInt32Array = []

@export var sdf: SDF   # assign a SDFSphere in the inspector
@export var iso_level: float = 0.0


func generate(size: int, iso: float, radius: float):
	# Prepare buffers
	vertices.clear()
	normals.clear()
	indices.clear()

	edge_vertex.resize(12)
	edge_normal.resize(12)

	# Sample density field
	var field = _sample_field(size)

	_march(field, size, iso)

	_build_mesh()

# ---------------------------------------------------------
# 1. Density sampling (object SDF)
# ---------------------------------------------------------
func _sample_density(p: Vector3) -> float:
	return sdf.sample(p)



# ---------------------------------------------------------
# 2. Marching loop
# ---------------------------------------------------------
func _march(field, size: int, iso: float):
	for x in range(size):
		for y in range(size):
			for z in range(size):
				_march_cell(field, x, y, z, iso)
				
	var min_d = 9999
	var max_d = -9999

	for x in range(size+1):
		for y in range(size+1):
			for z in range(size+1):
				var d = field[x][y][z]
				min_d = min(min_d, d)
				max_d = max(max_d, d)

	print("density range: ", min_d, " .. ", max_d)



# ---------------------------------------------------------
# 3. Optimized marching cell
# ---------------------------------------------------------
func _march_cell(field, x: int, y: int, z: int, iso: float):
	# Corner densities
	var d0 = field[x][y][z]
	var d1 = field[x+1][y][z]
	var d2 = field[x+1][y+1][z]
	var d3 = field[x][y+1][z]
	var d4 = field[x][y][z+1]
	var d5 = field[x+1][y][z+1]
	var d6 = field[x+1][y+1][z+1]
	var d7 = field[x][y+1][z+1]

	# Cube index
	var cube_index = 0
	if d0 < iso: cube_index |= 1
	if d1 < iso: cube_index |= 2
	if d2 < iso: cube_index |= 4
	if d3 < iso: cube_index |= 8
	if d4 < iso: cube_index |= 16
	if d5 < iso: cube_index |= 32
	if d6 < iso: cube_index |= 64
	if d7 < iso: cube_index |= 128

	# Early out
	var edge_mask = MC.get_edge_table()[cube_index]
	if edge_mask == 0:
		return

	# Corner positions
	var p0 = Vector3(x,   y,   z)
	var p1 = Vector3(x+1, y,   z)
	var p2 = Vector3(x+1, y+1, z)
	var p3 = Vector3(x,   y+1, z)
	var p4 = Vector3(x,   y,   z+1)
	var p5 = Vector3(x+1, y,   z+1)
	var p6 = Vector3(x+1, y+1, z+1)
	var p7 = Vector3(x,   y+1, z+1)

	# Interpolate active edges
	if edge_mask & 1:   edge_vertex[0]  = _vertex_interp(p0, p1, d0, d1, iso)
	if edge_mask & 2:   edge_vertex[1]  = _vertex_interp(p1, p2, d1, d2, iso)
	if edge_mask & 4:   edge_vertex[2]  = _vertex_interp(p2, p3, d2, d3, iso)
	if edge_mask & 8:   edge_vertex[3]  = _vertex_interp(p3, p0, d3, d0, iso)
	if edge_mask & 16:  edge_vertex[4]  = _vertex_interp(p4, p5, d4, d5, iso)
	if edge_mask & 32:  edge_vertex[5]  = _vertex_interp(p5, p6, d5, d6, iso)
	if edge_mask & 64:  edge_vertex[6]  = _vertex_interp(p6, p7, d6, d7, iso)
	if edge_mask & 128: edge_vertex[7]  = _vertex_interp(p7, p4, d7, d4, iso)
	if edge_mask & 256: edge_vertex[8]  = _vertex_interp(p0, p4, d0, d4, iso)
	if edge_mask & 512: edge_vertex[9]  = _vertex_interp(p1, p5, d1, d5, iso)
	if edge_mask & 1024: edge_vertex[10] = _vertex_interp(p2, p6, d2, d6, iso)
	if edge_mask & 2048: edge_vertex[11] = _vertex_interp(p3, p7, d3, d7, iso)

	# Emit triangles
	var tri_row = MC.get_tri_table()[cube_index]
	var i = 0
	while tri_row[i] != -1:
		var a = edge_vertex[tri_row[i]]
		var b = edge_vertex[tri_row[i+1]]
		var c = edge_vertex[tri_row[i+2]]

		var normal = ((b - a).cross(c - a)).normalized()

		var base = vertices.size()
		vertices.push_back(a)
		vertices.push_back(b)
		vertices.push_back(c)

		normals.push_back(normal)
		normals.push_back(normal)
		normals.push_back(normal)

		indices.push_back(base)
		indices.push_back(base + 1)
		indices.push_back(base + 2)

		i += 3


# ---------------------------------------------------------
# 4. Edge interpolation
# ---------------------------------------------------------
func _vertex_interp(p1: Vector3, p2: Vector3, v1: float, v2: float, iso: float) -> Vector3:
	if abs(iso - v1) < 0.00001:
		return p1
	if abs(iso - v2) < 0.00001:
		return p2
	if abs(v1 - v2) < 0.00001:
		return p1

	var t = (iso - v1) / (v2 - v1)
	return p1 + (p2 - p1) * t


# ---------------------------------------------------------
# 5. Mesh builder
# ---------------------------------------------------------
func _build_mesh():
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	$MeshInstance3D.mesh = mesh
	$MeshInstance3D.scale = Vector3(2, 2, 2)
	
	# place the mesh so its bottom sits at y = 0
	var aabb = mesh.get_aabb()
	
	#idk why this doesnt show
	spawn_debug_sphere(aabb.position, 100.0, Color(0.0, 1.0, 0.0, 1.0))
	
	$MeshInstance3D.transform.origin.x = -aabb.position.x * $MeshInstance3D.scale.x
	$MeshInstance3D.transform.origin.y = -aabb.position.y * $MeshInstance3D.scale.y
	$MeshInstance3D.transform.origin.z = -aabb.position.z * $MeshInstance3D.scale.z

	var origin = $MeshInstance3D.transform.origin
	
	#pre offset position
	spawn_debug_sphere(aabb.position, 1.0, Color(0.0, 1.0, 1.0, 1.0))

	var scale = $MeshInstance3D.scale

	print("AABB pos=", aabb.position,
		  "  scale=", scale,
		  "  computed offset=(",
		  -aabb.position.x * scale.x, ", ",
		  -aabb.position.y * scale.y, ", ",
		  -aabb.position.z * scale.z, ")",
		  "  final origin=", origin)
		
	print("Vertices: ", vertices.size())
	print("AABB: ", mesh.get_aabb())
	
	#post offset position
	spawn_debug_sphere($MeshInstance3D.transform.origin, 1.0, Color(1.0, 0.0, 1.0, 1.0))
	
	
	
func _sample_field(size: int) -> Array:
	var field := []
	field.resize(size + 1)

	var half = size * 0.5

	for x in range(size + 1):
		field[x] = []
		field[x].resize(size + 1)

		for y in range(size + 1):
			field[x][y] = []
			field[x][y].resize(size + 1)

			for z in range(size + 1):
				var p = Vector3(x, y, z) - Vector3(half, half, half)
				field[x][y][z] = _sample_density(p)

	# -------------------------------------------------
	# Diagnostic: print min/max density AFTER sampling
	# -------------------------------------------------
	var min_d = 99999.0
	var max_d = -99999.0

	for x in range(size + 1):
		for y in range(size + 1):
			for z in range(size + 1):
				var d = field[x][y][z]
				if d < min_d: min_d = d
				if d > max_d: max_d = d

	print("Density range: ", min_d, " .. ", max_d)

	return field



func spawn_debug_sphere(
		position: Vector3 = Vector3.ZERO,
		radius: float = 1.0,
		color: Color = Color(1.0, 1.0, 0.0, 1.0)
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
