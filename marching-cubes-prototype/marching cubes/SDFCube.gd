extends SDF
class_name SDFCube

@export var center: Vector3 = Vector3.ZERO
@export var side_length: float = 1.0

var h = side_length * 0.5

#this is the practice example but i need to debug it...

#define vertices
var v1 : Vector3 = center + Vector3(-h, -h, -h)
var v2 : Vector3 = center + Vector3( h, -h, -h)
var v3 : Vector3 = center + Vector3( h,  h, -h)
var v4 : Vector3 = center + Vector3(-h,  h, -h)
var v5 : Vector3 = center + Vector3(-h, -h,  h)
var v6 : Vector3 = center + Vector3( h, -h,  h)
var v7 : Vector3 = center + Vector3( h,  h,  h)
var v8 : Vector3 = center + Vector3(-h,  h,  h)


# define surface midpoints
var s1 : Vector3  = (v1 + v2 + v3 + v4) / 4.0 # Front face (z = -h)
var s2 : Vector3 = (v5 + v6 + v7 + v8) / 4.0 # Back face (z = +h)
var s3 : Vector3 = (v1 + v4 + v8 + v5) / 4.0 # Left face (x = -h)
var s4 : Vector3 = (v2 + v3 + v7 + v6) / 4.0 # Right face (x = +h)
var s5 : Vector3 = (v1 + v2 + v6 + v5) / 4.0 # Bottom face (y = -h)
var s6 : Vector3 = (v4 + v3 + v7 + v8) / 4.0 # Top face (y = +h)


#SDF should return >0 if we are outside the shape
#=0 if we are on the boundary
#<0 if we are inside the shape 



#SQUARE SDF:
#calculates perpendicular distance from the closest surface
func sample(p: Vector3) -> float:
	
	var surfaces : Array = [s1, s2, s3, s4, s5, s6]
	var i : int = 0 
	var closest_surface : Vector3
	var perp_dist : float
	var dist : float
	var min : float = 99999.9
	
	
	#find the closest surface
	while i < surfaces.size():
		dist = (p-surfaces[i]).length()
		if dist < min:
			min = dist
			closest_surface = surfaces[i]
		i+=1
	 
	
	#calculate perpendicular distance
	if closest_surface == s1:
		#perpendicular distance along z axis
		if p.z < s1.z:
			perp_dist = (s1.z - p.z)
		elif p.z > s1.z:
			perp_dist = -(s1.z - p.z)

	elif closest_surface == s2:
		#perpendicular distance along z axis
		if p.z < s2.z:
			perp_dist = (s2.z - p.z)
		elif p.z > s2.z:
			perp_dist = -(s2.z - p.z)
			
	elif closest_surface == s3:
		#perpendicular distance along x axis
		if p.x < s3.x:
			perp_dist = (s3.x - p.x)
		elif p.x > s3.x:
			perp_dist = -(s3.x - p.x)

	elif closest_surface == s4:
		#perpendicular distance along x axis
		if p.x < s4.x:
			perp_dist = (s4.x - p.x)
		elif p.x > s4.x:
			perp_dist = -(s4.x - p.x)
		
	elif closest_surface == s5:
		#perpendicular distance along y axis
		if p.y < s5.y:
			perp_dist = (s5.y - p.y)
		elif p.y < s5.y:
			perp_dist = -(s5.y - p.y)
		
	elif closest_surface == s6:
			#perpendicular distance along y axis
		if p.y < s6.y:
			perp_dist = (s6.y - p.y)
		elif p.y < s6.y:
			perp_dist = -(s5.y - p.y)
		
		
	if true and perp_dist< 0: 
		print("i: ", i)
		print("min: ", min)
		print("closest surface: ", closest_surface)
		print("input: ", p)
		print("output: ", perp_dist)
		print()
		
	return perp_dist
 
