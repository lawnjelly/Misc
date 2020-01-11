extends Node

func Rand_Angle()->float:
	return rand_range(deg2rad(45), deg2rad(90))

func VectorToAngle(a : Vector2)->float:
	return atan2(a.y, a.x)

func AngleToVector(angle : float)->Vector2:
	return Vector2(cos(angle), sin(angle))
	
func Vec2ToVec3(var v2 : Vector2, var h : float = 0.0)->Vector3:
	return Vector3(v2.x, h, v2.y)
