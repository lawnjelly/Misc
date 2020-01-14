extends Node

var id_counter : int = 0
var iteration_counter : int = 0
var m_ImmGeom : ImmediateGeometry

var m_File
var m_Line

enum eCellType {
	CT_GENERIC,
	CT_CORRIDOR,
	CT_POLY,
}

func ex_vec2(var v):
	ex_f(v.x, " ")
	ex_f(v.y)

func ex_vec3(var v):
	ex_f(v.x, " ")
	ex_f(v.y, " ")
	ex_f(v.z)
	
func ex_plane(var pl):
	ex_d(pl.x, " ")
	ex_d(pl.y, " ")
	ex_d(pl.z, " ")
	ex_d(pl.d)
	

func ex_f(var f, var spacer = ""):
	ex("%.2f" % f)
	ex(spacer)

func ex_d(var f, var spacer = ""):
	ex("%.3f" % f)
	ex(spacer)


func ex(var st):
	m_Line += st
	
func ex_line(var l):
	m_Line = l
	ex_newline()
	
func ex_newline():
	m_File.store_line(m_Line)
	print(m_Line)
	m_Line = ""


func Export_Level(var level : GLevel, var filename = "../test.lev"):
	var fi = File.new()
	m_File = fi
	if fi.open(filename, File.WRITE) != OK:
		return

	ex_line("# Lawnjelly Sector Level exporter 0.1")
	ex_line("num_sectors " + str(level.m_Cells.size()))
	ex_newline()
	
	var wall_count = 0
	for s in range (level.m_Cells.size()):
		wall_count = Export_Count_Walls(level, s, wall_count)

	
	for s in range (level.m_Cells.size()):
		Export_Sector(level, s)
	
	
	fi.close()

# do 2 passes, find the first wall in the bigger list
func Export_Count_Walls(var level : GLevel, var sect_id : int, var wall_count : int):
	var cell : GCell = level.m_Cells[sect_id]
	cell.m_FirstWall = wall_count
	wall_count += cell.m_Pts.size()
	return wall_count


func Export_Sector(var level : GLevel, var sect_id : int):
	var cell : GCell = level.m_Cells[sect_id]
	ex_line("sector " + str(sect_id))
	
	ex_line("\tnum_walls " + str(cell.get_num_walls()))
	
	ex_line("\tpoints")
	ex("\t\t")
	for p in range (cell.m_Pts.size()):
		ex_vec2(cell.m_Pts[p])
		ex(", ")
	ex_newline()

	ex_line("\tplanes")
	ex("\t\t")
	for p in range (cell.m_Planes.size()):
		ex_plane(-cell.m_Planes[p]) # point inward on export
		ex(", ")
	ex_newline()

	ex_line("\tlinks")
	ex("\t\t")
	for p in range (cell.m_LinkedCells.size()):
		ex(str(cell.m_LinkedCells[p]))
		ex(", ")
	ex_newline()
	
	ex_line("\tlinked_walls")
	ex("\t\t")
	for p in range (cell.m_LinkedWalls.size()):
		var link_wall_id = cell.m_LinkedWalls[p]
		
		# sync to first wall
		if link_wall_id != -1:
			# find linked sector
			var linked_sector_id = cell.m_LinkedCells[p]
			assert (linked_sector_id != -1)
			var ncell : GCell = level.m_Cells[linked_sector_id]
			link_wall_id += ncell.m_FirstWall
		
		ex(str(link_wall_id))
		ex(", ")
	ex_newline()
	

	ex("\tfloor_plane ")
	ex_plane(cell.m_Plane_Floor)
	ex_newline()
	ex("\tceil_plane ")
	ex_plane(-cell.m_Plane_Ceiling) # point down on export
	ex_newline()

	ex_line("\tfloors")
	ex("\t\t")
	for p in range (cell.m_hFloor.size()):
		ex_f(cell.m_hFloor[p])
		ex(", ")
	ex_newline()

	ex_line("\tceils")
	ex("\t\t")
	for p in range (cell.m_hCeil.size()):
		ex_f(cell.m_hCeil[p])
		ex(", ")
	ex_newline()
	

class GCell:
	var m_ID : int
	var m_ptCentre : Vector2 = Vector2()
	var m_Pts = []
	var m_Planes = []
	var m_Angles = []
	var m_LinkedCells = []
	var m_LinkedWalls = []
	var m_bLinkAllowed = []

	var m_hFloor = []
	var m_hCeil = []
	var m_Plane_Floor : Plane = Plane(Vector3(0, 1, 0), 0)
	var m_Plane_Ceiling : Plane = Plane(Vector3(0, -1, 0), -2)
	
	var type : int # eCellType
	var node : Spatial
	var aabb : AABB
	
	var m_FirstWall : int # used at export
	
	func is_wall_portal(var i : int)->bool:
		return m_LinkedCells[i] != -1
	
	func get_num_walls()->int:
		return m_Pts.size()
		
	func get_linked_wall_heights(var level : GLevel, var w : int)->Quat:
		var nc : int = m_LinkedCells[w]
		var nw : int = m_LinkedWalls[w]
		assert (nc != -1)
		assert (nw != -1)
		var ncell : GCell = level.m_Cells[nc]
		var nw2 : int = (nw+1) % ncell.get_num_walls()
		var fh0 : float = ncell.m_hFloor[nw]
		var fh1 : float = ncell.m_hFloor[nw2]
		var ch0 : float = ncell.m_hCeil[nw]
		var ch1 : float = ncell.m_hCeil[nw2]
		return Quat(fh1, fh0, ch1, ch0) # reversed because neighbour cell will have opposite polarity
		

	
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
		
		if ncell.aabb.intersects(cell.aabb) == false:
			continue
		
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

