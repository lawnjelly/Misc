extends Node

const MIN_CEILING_HEIGHT = 2.0



func Create(var parent):
	#var ang = GHelp.VectorToAngle(Vector2(1, 1))
	#var vec = GHelp.AngleToVector(ang)
	
	var nTries = 512#512
	
	for t in range (nTries):
		
		if (Graph.m_Abort):
			print ("aborting")
			break
		#print("Try " + str(t))
		
		if t == 0:
			Cell_Create(-1, -1)
		else:
			var nCells = Graph.m_Level.m_Cells.size()
			#var ncell_id : int =  nCells - 1
			var ncell_id : int = randi() % nCells
			var ncell : Graph.GCell = Graph.m_Level.m_Cells[ncell_id]
			var nWalls : int = ncell.get_num_walls()
			var nwall : int = randi() % nWalls
			
			if ncell.m_bLinkAllowed[nwall] == false:
				continue
			
			if ncell.m_LinkedCells[nwall] != -1:
				continue
				
			# max length for start of room
			#var length : float = CalcWallLength(ncell, nwall)
			#if length > 7.0:
			#	continue
				
			Cell_Create(ncell_id, nwall)
		
#	for c in range (nCells):
#		Cell_Link(c, (c+1) % nCells)
	Graph.Export_Level(Graph.m_Level, "../test.lev")
	
	
	for c in range (Graph.m_Level.m_Cells.size()):
		Cell_CreateGeometry(c, parent)
		
	print ("created " + str(Graph.m_Level.m_Cells.size()) + " cells")
	#for c in range (1):
	#	Iterate()
	pass
	
func CalcWallLength(var cell : Graph.GCell, var wall_id : int):
	var v0 : Vector2 = cell.m_Pts[wall_id]
	wall_id = (wall_id + 1) % cell.get_num_walls()
	var v1 : Vector2 = cell.m_Pts[wall_id]
	return (v1 - v0).length()

func MakeRoom_Generic(var cell : Graph.GCell):
	cell.type = Graph.eCellType.CT_GENERIC
	
	var bComplete = false
	
	while (bComplete == false):
		bComplete = Cell_AddWall(cell)

func AddWall_Generic(var cell : Graph.GCell, var angle_change : float, var dist : float, var bLinkAllowed : bool = true):
	var nWalls = cell.get_num_walls()-1
	var ang = cell.m_Angles[nWalls-1] + angle_change
	var offset = GHelp.AngleToVector(ang) * dist
	var p0 : Vector2 = cell.m_Pts[nWalls]
	var p1 : Vector2 = p0 + offset
	cell.m_Pts.push_back(p1)
	_AddWall_ExceptPoint(cell, ang, p0, p1, bLinkAllowed)

func AddWall_Close(var cell : Graph.GCell, var bLinkAllowed : bool = true):
	var nWalls = cell.get_num_walls()-1
	var p0 : Vector2 = cell.m_Pts[nWalls]
	var p1 : Vector2 = cell.m_Pts[0]
	var ang = GHelp.VectorToAngle(p1 - p0)
	_AddWall_ExceptPoint(cell, ang, p0, p1, bLinkAllowed)

func _AddWall_ExceptPoint(var cell : Graph.GCell, var angle : float, var p0 : Vector2, var p1 : Vector2, var bLinkAllowed : bool, var linked_cell : int = -1, var linked_wall : int = -1):
	cell.m_Angles.push_back(angle)
	cell.m_Planes.push_back(CalculatePlane(p0, p1))
	cell.m_LinkedCells.push_back(linked_cell)
	cell.m_LinkedWalls.push_back(linked_wall)
	cell.m_bLinkAllowed.push_back(bLinkAllowed)
	

func MakeRoom_Corridor(var cell : Graph.GCell):
	cell.type = Graph.eCellType.CT_CORRIDOR
	
	# get the first 2 points
	var p0 : Vector2 = cell.m_Pts[0]
	var p1 : Vector2 = cell.m_Pts[1]
	
	var distA : float = (p1 - p0).length()
	
	var max_length = 8.0
	if distA < 3.0:
		max_length *= 3
		
	var distB : float = rand_range(2.0, max_length)
	
	var ang = (PI/2)
	
	AddWall_Generic(cell, ang, distB, false)
	AddWall_Generic(cell, ang, distA)
	AddWall_Close(cell, false)


func MakeRoom_Poly(var cell : Graph.GCell):
	cell.type = Graph.eCellType.CT_POLY
	
	# get the first 2 points
	var p0 : Vector2 = cell.m_Pts[0]
	var p1 : Vector2 = cell.m_Pts[1]
	
	var distA : float = (p1 - p0).length()
	
	# choose a number of sides
	var nSides = (randi() % 4)
	if nSides == 0:
		nSides = 9
	nSides += 3
	
	var ang = (2 * PI) / nSides

	for s in range (nSides-2):
		AddWall_Generic(cell, ang, distA)
		
	AddWall_Close(cell)


func Cell_Create(var parent_cell : int, var parent_wall : int):
	var cell = Graph.GCell.new()
	var new_cell_id = Graph.m_Level.m_Cells.size()
	
	# add first wall to match parent 
	if parent_cell == -1:
		var p0 = Vector2(0, 0)
		var p1 = Vector2(4, 0)
		cell.m_Pts.push_back(p0)
		cell.m_Pts.push_back(p1)
		_AddWall_ExceptPoint(cell, 0.0, p0, p1, true)
#		cell.m_Pts.push_back(Vector2(0, 0))
#		cell.m_Pts.push_back(Vector2(4, 0))
#		cell.m_Angles.push_back(0.0)
#		cell.m_LinkedCells.push_back(-1)
#		cell.m_bLinkAllowed.push_back(true)
	else:
		var pcell : Graph.GCell = Graph.m_Level.m_Cells[parent_cell]
		var pwall2 : int = (parent_wall + 1) % pcell.get_num_walls()
		var p0 = pcell.m_Pts[pwall2]
		var p1 = pcell.m_Pts[parent_wall]
		cell.m_Pts.push_back(p0)
		cell.m_Pts.push_back(p1)
		var angle = pcell.m_Angles[parent_wall] + PI
		_AddWall_ExceptPoint(cell, angle, p0, p1, false, parent_cell, parent_wall)
		
#		cell.m_Pts.push_back(pcell.m_Pts[pwall2])
#		cell.m_Pts.push_back(pcell.m_Pts[parent_wall])
#		cell.m_Angles.push_back(pcell.m_Angles[parent_wall] + PI)
#		cell.m_LinkedCells.push_back(parent_cell)
#		cell.m_bLinkAllowed.push_back(false)
		
		
	
#	var plane = CalculatePlane(cell.m_Pts[0], cell.m_Pts[1])
#	cell.m_Planes.push_back(plane)


	var rtype : int = randi() % 3
	#var rtype : int = 2
	match rtype:
		0:
			MakeRoom_Generic(cell)
		1:
			MakeRoom_Corridor(cell)
		2:
			MakeRoom_Poly(cell)
	

	Cell_CreateFloorAndCeiling(cell, parent_cell, parent_wall)
	Cell_CalcAABB(cell)

	if Graph.Cell_TestCollisions(cell, parent_cell) == false:
		# revert any links?
		return
	
	# make back link to parent
	if parent_cell != -1:
		var pcell : Graph.GCell = Graph.m_Level.m_Cells[parent_cell]
		pcell.m_LinkedCells[parent_wall] = new_cell_id
		pcell.m_LinkedWalls[parent_wall] = 0 # always first wall on this side

	# record the cell ID in the cell	
	cell.m_ID = Graph.m_Level.m_Cells.size()

	assert (cell.m_LinkedCells.size() == cell.m_LinkedWalls.size())
	
	Graph.m_Level.m_Cells.push_back(cell)


func CalculatePlane(var v0 : Vector2, var v1 : Vector2)->Plane:
	return Plane(GHelp.Vec2ToVec3(v1), GHelp.Vec2ToVec3(v1, 1.0), GHelp.Vec2ToVec3(v0))
	
	
func Cell_Debug(var cell_id):
	print("cell " + str(cell_id))
	var cell : Graph.GCell = Graph.m_Level.m_Cells[cell_id]
	var nWalls = cell.get_num_walls()
	for w in range (nWalls):
		print("\twall " + str(w))

func DebugOut(var sz):
	if Graph.m_Level.m_Cells.size() > 14:
		print(sz)



func Cell_AddWall(var cell : Graph.GCell):
	var p_prev = cell.get_num_walls()-1
	var w_prev = cell.get_num_walls()-2
	assert (w_prev >= 0)
	
	var ptStart : Vector2 = cell.m_Pts[0]
	var ptLeft : Vector2 = cell.m_Pts[p_prev]
	var angle : float = cell.m_Angles[w_prev]
	
	angle += GHelp.Rand_Angle()
	if (angle > (2 * PI)):
		angle -= (2 * PI)
	
	var dist : float = rand_range(2.0, 8.0)
	var pt : Vector2 = ptLeft + (GHelp.AngleToVector(angle) * dist)
	
	var plane : Plane = CalculatePlane(ptLeft, pt)
	var bClosed : bool = false
	
	
	# detect situation where we must close the cell to remain convex
	# and override this new wall
	var plane_first = cell.m_Planes[0]
	
	if plane_first.distance_to(GHelp.Vec2ToVec3(pt)) > -0.5:
		bClosed = true
	
			
	# if the start point is in front of the plane, we are folding in on ourself so will close
	# i.e. going for a second loop
	if plane.distance_to(GHelp.Vec2ToVec3(ptStart)) > 0.0:
		bClosed = true
		
			
	if bClosed:
		# conditions to close
		angle = GHelp.VectorToAngle(ptStart - ptLeft)
		pt = ptStart
		# calculate the plane again
		plane = CalculatePlane(ptLeft, pt)
		
	
	
	# add the wall
	if bClosed == false:
		cell.m_Pts.push_back(pt)
		
	cell.m_Angles.push_back(angle)
	cell.m_LinkedCells.push_back(-1)
	cell.m_LinkedWalls.push_back(-1)
	cell.m_bLinkAllowed.push_back(true)
	cell.m_Planes.push_back(plane)
	
	
	#print("adding wall from " + str(ptLeft) + " to " + str(pt))
	
	return bClosed

func Cell_CalcAABB(var cell : Graph.GCell):
	cell.aabb = AABB(GHelp.Vec2ToVec3(cell.m_Pts[0], cell.m_hFloor[0]), Vector3(0, 0, 0))
	
	for w in range (cell.get_num_walls()):
		var pt = cell.m_Pts[w]
		cell.aabb = cell.aabb.expand(GHelp.Vec2ToVec3(pt, cell.m_hFloor[w]))
		cell.aabb = cell.aabb.expand(GHelp.Vec2ToVec3(pt, cell.m_hFloor[w] + cell.m_hCeil[w]))

func Modify_PortalFloorAndCeiling(var f, var c)->Vector2:
	var res = Vector2(f, c)
	
	if (randi() % 3) != 0:
		return res

	if c > (MIN_CEILING_HEIGHT + 1.0):
		var diff = c - MIN_CEILING_HEIGHT
		c = MIN_CEILING_HEIGHT
		f += c/2
	
	
	
	res.x = f
	res.y = c
	
	return res


func Cell_CreateFloorAndCeiling(var cell : Graph.GCell, var parent_cell_id : int, var parent_wall : int):
	# first identify the link heights and ceiling
	var f0 = 0.0
	var f1 = 0.0
	var c0 = MIN_CEILING_HEIGHT + 2.0
	var c1 = MIN_CEILING_HEIGHT + 2.0
	var p0 = cell.m_Pts[0]
	var p1 = cell.m_Pts[1]
	var p2 = cell.m_Pts[2]

	# calculate a sensible 3rd point from which to make the plane
#	var p2 = p1 - p0
#	p2 = Vector2(p2.y, p2.x)
#	p2 = p2.normalized()
#	p2 *= 6.0
#	p2 += p0
	
	if parent_cell_id != -1:
		var pcell : Graph.GCell = Graph.m_Level.m_Cells[parent_cell_id]
		var w = parent_wall
		var w2 = (w + 1) % pcell.get_num_walls()
		f0 = pcell.m_hFloor[w2]
		f1 = pcell.m_hFloor[w]
		c0 = pcell.m_hCeil[w2]
		c1 = pcell.m_hCeil[w]
		
		var temp = Modify_PortalFloorAndCeiling(f0, c0)
		f0 = temp.x
		f1 = temp.x
		c0 = temp.y
		c1 = temp.y
	
	# random height change
	var max_change = 5.0
	var max_ceil_change = 5.0
	var change = 0.0
	var ceil_change = 0.0
	if cell.type == Graph.eCellType.CT_CORRIDOR:
	#if false:
		change = rand_range(-max_change, max_change)
		ceil_change = rand_range(-max_ceil_change, max_ceil_change)
	var f2 = f0 + change
	var c2 = c0 + ceil_change
	
	# min ceiling height
	if c2 < MIN_CEILING_HEIGHT:
		c2 = MIN_CEILING_HEIGHT
	if c2 > 20.0:
		c2 = 20.0
	
	# calc planes
	cell.m_Plane_Floor = Plane(GHelp.Vec2ToVec3(p0, f0), GHelp.Vec2ToVec3(p1, f1), GHelp.Vec2ToVec3(p2, f2))
	cell.m_Plane_Ceiling = Plane(GHelp.Vec2ToVec3(p0, c0), GHelp.Vec2ToVec3(p1, c1), GHelp.Vec2ToVec3(p2, c2))
	
	for w in range (cell.get_num_walls()):
		var floor_h = CalcPlaneHeight(cell.m_Plane_Floor, cell.m_Pts[w])
		cell.m_hFloor.push_back(floor_h)
		var ceil_h = CalcPlaneHeight(cell.m_Plane_Ceiling, cell.m_Pts[w])
		cell.m_hCeil.push_back(ceil_h)
	
	pass

func CalcPlaneHeight(var p : Plane, var pt : Vector2)->float:
	var intersection = p.intersects_ray(GHelp.Vec2ToVec3(pt, 1000.0), Vector3(0, -1, 0))
	return intersection.y

func Cell_CreateGeometry(var cell_id, var parent):
	var cell : Graph.GCell = Graph.m_Level.m_Cells[cell_id]
	
	var spatial = Spatial.new()
	parent.add_child(spatial)
	spatial.set_name("room_" + str(cell_id))
	cell.node = spatial
	
	Cell_CreateGeometry_Walls(cell, spatial)
	Cell_CreateGeometry_Portals(cell, spatial)
	Cell_CreateGeometry_Floors(cell, spatial)
	Cell_CreateGeometry_Ceilings(cell, spatial)
	
	
	
func Cell_CreateGeometry_Walls(var cell : Graph.GCell, var spatial : Spatial):
	
	var mi_walls = MeshInstance.new()
	spatial.add_child(mi_walls)
	mi_walls.set_name("walls")
	
	var mesh = mi_walls.mesh
	
	var tmpMesh = Mesh.new()
	
#	var mat = SpatialMaterial.new()
#	var color = Color(0.1, 0.8, 0.1)
#	mat.params_cull_mode = SpatialMaterial.CULL_DISABLED
#	mat.vertex_color_use_as_albedo = true
#
#	var mat2 = SpatialMaterial.new()
#	var color2 = Color(0.8, 0.1, 0.1)
#	mat2.albedo_color = color2
#	mat2.params_cull_mode = SpatialMaterial.CULL_DISABLED

	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(Scene.m_mat_Wall)

	var l0 = 0.0
	var l1 = 0.0

	var nWalls : int = cell.m_Pts.size()
	for w in nWalls:
		var w2 : int = (w + 1) % nWalls

		var p0 = cell.m_Pts[w]
		var p1 = cell.m_Pts[w2]
		
		# length for calculating uvs
		l0 = l1
		l1 += (p1-p0).length()
		
		
		var f0 = cell.m_hFloor[w]
		var f1 = cell.m_hFloor[w2]
		
		var c0 = cell.m_hCeil[w]
		var c1 = cell.m_hCeil[w2]
		
		var norm = -cell.m_Planes[w].normal

		# if it is a portal, there may still be a bottom and top wall segment
		if cell.is_wall_portal(w):
			var q = cell.get_linked_wall_heights(Graph.m_Level, w)
			
			# the opposite wall is taller than this one, no wall segments to draw
			# this side
			if q.z < c0:
				# ceiling of bottom segment
				var c2 = q.x - f0
				var c3 = q.y - f1
				
				if c3 > 0.0:
					Geom_AddWallSegment(st, norm, p0, p1, f0, f1, c2, c3, l0, l1)
					
				var f2 = q.x + q.z
				var f3 = q.y + q.w
				
				c2 = (f0 + c0) - f2
				c3 = (f1 + c1) - f3
				
				if c2 > 0.0:
					Geom_AddWallSegment(st, norm, p0, p1, f2, f3, c2, c3, l0, l1)
					
		else:
			# normal wall
			Geom_AddWallSegment(st, norm, p0, p1, f0, f1, c0, c1, l0, l1)
		
	st.commit(tmpMesh)

	mi_walls.mesh = tmpMesh

func Geom_AddWallSegment(var st, var norm, var p0, var p1, var f0, var f1, var c0, var c1, var l0, var l1):
		var v0 = GHelp.Vec2ToVec3(p0, f0)
		var v1 = GHelp.Vec2ToVec3(p0, f0 + c0)
		var v2 = GHelp.Vec2ToVec3(p1, f1 + c1)
		var v3 = GHelp.Vec2ToVec3(p1, f1)
		
		var uv0 = Vector2(l0, v0.y)
		var uv1 = Vector2(l0, v1.y)
		var uv2 = Vector2(l1, v2.y)
		var uv3 = Vector2(l1, v3.y)
		
		var tex_scale = 0.2
		uv0 *= tex_scale
		uv1 *= tex_scale
		uv2 *= tex_scale
		uv3 *= tex_scale
		
		st.add_normal(norm)
		st.add_uv(uv0)
		st.add_vertex(v0)
		st.add_normal(norm)
		st.add_uv(uv1)
		st.add_vertex(v1)
		st.add_normal(norm)
		st.add_uv(uv2)
		st.add_vertex(v2)
		
		st.add_normal(norm)
		st.add_uv(uv0)
		st.add_vertex(v0)
		st.add_normal(norm)
		st.add_uv(uv2)
		st.add_vertex(v2)
		st.add_normal(norm)
		st.add_uv(uv3)
		st.add_vertex(v3)

func Cell_CreateGeometry_Portals(var cell : Graph.GCell, var room : Spatial):
	

	var nWalls : int = cell.m_Pts.size()
	for w in nWalls:
		var w2 : int = (w + 1) % nWalls
		
		if cell.is_wall_portal(w) == false:
			continue

		var linked_id = cell.m_LinkedCells[w]
		if linked_id < cell.m_ID:
			continue
			
		# separate mesh for each portal
		var mi = MeshInstance.new()
		room.add_child(mi)
		mi.set_name("portal_" + str(linked_id))
		
		var mesh = mi.mesh
		
		var tmpMesh = Mesh.new()
	
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_material(Scene.m_mat_Portal)
			
			
		# we want to get the portal heights from the wall we
		# are linking to .. because it can be shorter than the opening from here
		var qheight : Quat = cell.get_linked_wall_heights(Graph.m_Level, w)

		var h0 = qheight.x
		var h1 = qheight.y

		var ceil0 = qheight.z
		var ceil1 = qheight.w
			
#		var h0 = cell.m_hFloor[w]
#		var h1 = cell.m_hFloor[w2]
#
#		var ceil0 = cell.m_hCeil[w]
#		var ceil1 = cell.m_hCeil[w2]
		
		var v0 = GHelp.Vec2ToVec3(cell.m_Pts[w], h0)
		var v1 = GHelp.Vec2ToVec3(cell.m_Pts[w], h0 + ceil0)
		var v2 = GHelp.Vec2ToVec3(cell.m_Pts[w2], h1 + ceil1)
		var v3 = GHelp.Vec2ToVec3(cell.m_Pts[w2], h1)
		
		var norm = cell.m_Planes[w].normal
		st.add_normal(norm)
		st.add_vertex(v0)
		st.add_vertex(v1)
		st.add_vertex(v2)
		st.add_vertex(v3)
#		st.add_normal(norm)
#		st.add_vertex(v2)
#		st.add_normal(norm)
#		st.add_vertex(v1)
#
#		st.add_normal(norm)
#		st.add_vertex(v0)
#		st.add_normal(norm)
#		st.add_vertex(v3)
#		st.add_normal(norm)
#		st.add_vertex(v2)
		
		st.add_index(0)
		st.add_index(2)
		st.add_index(1)
		st.add_index(0)
		st.add_index(3)
		st.add_index(2)
		
		st.commit(tmpMesh)
	
		mi.mesh = tmpMesh

func Cell_CreateGeometry_Floors(var cell : Graph.GCell, var spatial : Spatial):
	
	var mi_walls = MeshInstance.new()
	spatial.add_child(mi_walls)
	mi_walls.set_name("floor")
	
	var mesh = mi_walls.mesh
	
	var tmpMesh = Mesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(Scene.m_mat_Floor)

	var nWalls : int = cell.m_Pts.size()
	
	# calc normal
	var p0 = cell.m_Pts[0]
	var p1 = cell.m_Pts[1]
	var p2 = cell.m_Pts[2]
	
	var v0 = GHelp.Vec2ToVec3(p0, cell.m_hFloor[0])
	var v1 = GHelp.Vec2ToVec3(p1, cell.m_hFloor[1])
	var v2 = GHelp.Vec2ToVec3(p2, cell.m_hFloor[2])
	var norm = Plane(v0, v1, v2).normal
	st.add_normal(norm)
	
	# verts
	for w in nWalls:
		var pt = cell.m_Pts[w]
		var vt = GHelp.Vec2ToVec3(pt, cell.m_hFloor[w])
		var tex_scale = 0.2
		pt *= tex_scale
		st.add_uv(pt)
		st.add_vertex(vt)
		
	# indices
	for w in nWalls:
		var w2 : int = (w + 1) % nWalls
		
		st.add_index(0)
		st.add_index(w)
		st.add_index(w2)
	
		
	
#	for w in nWalls:
#		var w2 : int = (w + 1) % nWalls
#
#		var p0 = cell.m_Pts[0]
#		var p1 = cell.m_Pts[w]
#		var p2 = cell.m_Pts[w2]
#
#		var v0 = GHelp.Vec2ToVec3(p0, cell.m_hFloor[0])
#		var v1 = GHelp.Vec2ToVec3(p1, cell.m_hFloor[w])
#		var v2 = GHelp.Vec2ToVec3(p2, cell.m_hFloor[w2])
#
#		var tex_scale = 0.1
#		p0 *= tex_scale
#		p1 *= tex_scale
#		p2 *= tex_scale
#
#		var norm = Plane(v0, v1, v2).normal
#		st.add_normal(norm)
#		st.add_uv(p0)
#		st.add_vertex(v0)
#		st.add_normal(norm)
#		st.add_uv(p1)
#		st.add_vertex(v1)
#		st.add_normal(norm)
#		st.add_uv(p2)
#		st.add_vertex(v2)
		
		
	st.commit(tmpMesh)

	mi_walls.mesh = tmpMesh


func Cell_CreateGeometry_Ceilings(var cell : Graph.GCell, var spatial : Spatial):
	
	var mi = MeshInstance.new()
	spatial.add_child(mi)
	mi.set_name("ceiling")
	
	var mesh = mi.mesh
	
	var tmpMesh = Mesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(Scene.m_mat_Floor)

	var nWalls : int = cell.m_Pts.size()
	
	# calc normal
	var p0 = cell.m_Pts[0]
	var p1 = cell.m_Pts[1]
	var p2 = cell.m_Pts[2]
	
	var v0 = GHelp.Vec2ToVec3(p0, cell.m_hFloor[0] + cell.m_hCeil[0])
	var v1 = GHelp.Vec2ToVec3(p1, cell.m_hFloor[1] + cell.m_hCeil[1])
	var v2 = GHelp.Vec2ToVec3(p2, cell.m_hFloor[2] + cell.m_hCeil[2])
	var norm = Plane(v0, v1, v2).normal
	st.add_normal(-norm)
	
	# verts
	for w in nWalls:
		var pt = cell.m_Pts[w]
		var vt = GHelp.Vec2ToVec3(pt, cell.m_hFloor[w] + cell.m_hCeil[w])
		var tex_scale = 0.1
		pt *= tex_scale
		st.add_uv(pt)
		st.add_vertex(vt)
		
	# indices
	for w in nWalls:
		var w2 : int = (w + 1) % nWalls
		
		st.add_index(0)
		st.add_index(w2)
		st.add_index(w)
	
		
	st.commit(tmpMesh)

	mi.mesh = tmpMesh
