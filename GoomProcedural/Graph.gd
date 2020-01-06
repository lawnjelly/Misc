extends Node

var id_counter : int = 0
var iteration_counter : int = 0
var m_ImmGeom : ImmediateGeometry

enum eCellType {
	CT_GENERIC,
	CT_CORRIDOR,
	CT_POLY,
}



#class GWall:
#	var id : int = 0
#	var ptLeft_local : Vector2 = Vector2()
#	var ptRight_local : Vector2 = Vector2()
#	var ptLeft_world : Vector2 = Vector2()
#	var ptRight_world : Vector2 = Vector2()
#
#	var ptCentre_local : Vector2 = Vector2()
#	var ptCentre_world : Vector2 = Vector2()
#	var size : float = 1.0
#
#	var bPortal = false
#	var linked_id : int = -1
#	var linked_dist : float = 1000000.0
#
#	func ptLeft_local3():
#		return Vector3(ptLeft_local.x, 0, ptLeft_local.y)
#	func ptRight_local3():
#		return Vector3(ptRight_local.x, 0, ptRight_local.y)
#	func ptTop_local3():
#		return Vector3(ptLeft_local.x, 1, ptLeft_local.y)
#
#
#	func ptBotLeft():
#		return Vector3(ptLeft_local.x, 0, ptLeft_local.y)
#	func ptBotRight():
#		return Vector3(ptRight_local.x, 0, ptRight_local.y)
#	func ptTopLeft():
#		return Vector3(ptLeft_local.x, 2, ptLeft_local.y)
#	func ptTopRight():
#		return Vector3(ptRight_local.x, 2, ptRight_local.y)
#
#	func update_world_pos(var cell : GCell):
#		ptCentre_world = cell.xform_point(ptCentre_local)
#		ptLeft_world = cell.xform_point(ptLeft_local)
#		ptRight_world = cell.xform_point(ptRight_local)
#
#		calculate_world_plane()
#
#		if bPortal:
#			cell.indicator.translation = Vector3(ptCentre_world.x, 0, ptCentre_world.y)
#
#	func calculate_world_plane():
#		plane_world = Plane(GHelp.Vec2ToVec3(ptRight_world), GHelp.Vec2ToVec3(ptRight_world, 1.0), GHelp.Vec2ToVec3(ptLeft_world))
#
#
#	func calculate_local_plane():
#		plane_local = Plane(ptRight_local3(), ptTop_local3(), ptLeft_local3())
#
#	func debug_string():
#		var sz = ""
#		sz += "from " + str(ptLeft_local)
#		sz += "\tto " + str(ptRight_local)
#		sz += "\tangle " + str(rad2deg(angle))
#		sz += "\tplane " + str(plane_local)
#		return sz
#
#	var angle : float # from north in local space
#	var plane_local : Plane = Plane()
#	var plane_world : Plane = Plane()

class GCell:
	var m_ptCentre : Vector2 = Vector2()
	var m_Pts = []
	var m_Heights = []
	var m_Planes = []
	var m_Angles = []
	var m_LinkedCells = []
	var m_bLinkAllowed = []
	
	var type : int # eCellType
	var node : Spatial
	var aabb : Rect2
	
	func is_wall_portal(var i : int)->bool:
		return m_LinkedCells[i] != -1
	
	func get_num_walls()->int:
		return m_Pts.size()
	
class GLevel:
	var m_Cells = []


var m_Level : GLevel = GLevel.new()
var m_Abort : bool = false



# test a cell before allowing it to be added
func Cell_TestCollisions(var cell : GCell, var ignore_cell_id : int = -1)->bool:
	
	var nCells = m_Level.m_Cells.size()
	var nWalls : int = cell.get_num_walls()

	var ptCentre = Vector2()
	for p in cell.m_Pts.size():
		ptCentre += cell.m_Pts[p]
	ptCentre /= cell.m_Pts.size()
	cell.m_ptCentre = ptCentre
	
	for c in nCells:
		if c == ignore_cell_id:
			continue
		
		var ncell : GCell = Graph.m_Level.m_Cells[c]
		
		for p in ncell.m_Pts.size():
			# point in cell?
			if IsPointInCell(ncell.m_Pts[p], cell):
				return false
				
		# need to do the other way check as well, points of the cell within the neighbour
		for p in cell.m_Pts.size():
			if IsPointInCell(cell.m_Pts[p], ncell):
				return false
				
				
		# final test has to deal with polys overlapping but none of the points
		# being within one another. This does occur when one box stretches over another.
		#if IsPointInCell(ncell.m_ptCentre, cell):
		#	return false
	
		# finally test for intersections between the edges of each cell
		var nWalls2 : int = ncell.get_num_walls()
		for w in nWalls:
			var p0 : Vector2 = cell.m_Pts[w]
			var p1 : Vector2 = cell.m_Pts[(w+1) % nWalls]

			for w2 in nWalls2:
				var p2 : Vector2 = ncell.m_Pts[w2]
				var p3 : Vector2 = ncell.m_Pts[(w2+1) % nWalls2]
				
				var res = Geometry.segment_intersects_segment_2d(p0, p1, p2, p3)
				
				if res:
					# ignore conditions .. sharing
					if ((p0 == p2) or (p0 == p3) or (p1 == p2) or (p1 == p3)) == false:
						return false
#					else:
#						print ("res is " + str(res))
#						m_Abort = true
#						return true
	return true
	
func IsPointInCell(var pt : Vector2, var cell : GCell)->bool:
	var pt3 : Vector3 = GHelp.Vec2ToVec3(pt)
	
	for w in cell.get_num_walls():
		var wplane : Plane = cell.m_Planes[w]
		
		var dist : float = wplane.distance_to(pt3)
		
		if dist >= 0.0:
			return false
		
	return true

