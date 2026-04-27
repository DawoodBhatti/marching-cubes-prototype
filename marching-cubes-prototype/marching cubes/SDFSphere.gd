extends SDF
class_name SDFSphere

@export var center: Vector3 = Vector3.ZERO
@export var radius: float =  sqrt(3)

func sample(p: Vector3) -> float:
	return (p - center).length() - radius
