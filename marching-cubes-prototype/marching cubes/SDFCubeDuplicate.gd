extends SDF
class_name SDFCubeDuplicate

@export var center: Vector3 = Vector3.ZERO
@export var side_length: float = 1.0

var h = side_length * 0.5
var half_extents = Vector3(h, h, h)

func sample(p: Vector3) -> float:
	var q = p.abs() - half_extents
	var outside = Vector3(
		max(q.x, 0.0),
		max(q.y, 0.0),
		max(q.z, 0.0)
	)
	return outside.length() + min(max(q.x, max(q.y, q.z)), 0.0)

 
