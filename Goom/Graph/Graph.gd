extends Node

class GSector:
	var m_FirstWall : int
	var m_NumWalls : int


var m_NumSectors : int
var m_Sectors = []
var m_Pts = []
var m_Planes = []
var m_LinkedSectors = []
var m_FloorPlanes = []
var m_CeilPlanes = []
var m_SectorCentres = []

func clear():
	m_NumSectors = 0
	m_Pts.clear()
	m_Planes.clear()
	m_LinkedSectors.clear()
	m_FloorPlanes.clear()
	m_CeilPlanes.clear()
	m_SectorCentres.clear()

# naive, slow
func find_sector(var pt : Vector3)->int:
	for s in range (m_NumSectors):
		if is_point_within_sector(s, pt):
			return s
			
	return -1

func is_point_within_sector(var sid : int, var pt : Vector3)->bool:
	var s : GSector = m_Sectors[sid]

	for w in range (s.m_NumWalls):
		var wid = w + s.m_FirstWall
		var plane : Plane = m_Planes[wid]
		var dist = plane.distance_to(pt)
		if dist < 0.0:
			return false
		
	var fdist = m_FloorPlanes[sid].distance_to(pt)
	if fdist < 0.0:
		return false
		
	var cdist = m_CeilPlanes[sid].distance_to(pt)
	if fdist < 0.0:
		return false
	
	return true


