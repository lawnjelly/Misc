extends Node



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
	
	
	for c in range (Graph.m_Level.m_Cells.size()):
		Cell_CreateGeometry(c, parent)
		
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
	cell.m_Angles.push_back(ang)
	cell.m_Planes.push_back(CalculatePlane(p0, p1))
	cell.m_LinkedCells.push_back(-1)
	cell.m_bLinkAllowed.push_back(bLinkAllowed)

func AddWall_Close(var cell : Graph.GCell, var bLinkAllowed : bool = true):
	var nWalls = cell.get_num_walls()-1
	var p0 : Vector2 = cell.m_Pts[nWalls]
	var p1 : Vector2 = cell.m_Pts[0]
	var ang = GHelp.VectorToAngle(p1 - p0)
	cell.m_Angles.push_back(ang)
	cell.m_Planes.push_back(CalculatePlane(p0, p1))
	cell.m_LinkedCells.push_back(-1)
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
		cell.m_Pts.push_back(Vector2(0, 0))
		cell.m_Pts.push_back(Vector2(4, 0))
		cell.m_Angles.push_back(0.0)
		cell.m_LinkedCells.push_back(-1)
		cell.m_bLinkAllowed.push_back(true)
	else:
		var pcell : Graph.GCell = Graph.m_Level.m_Cells[parent_cell]
		var pwall2 : int = (parent_wall + 1) % pcell.get_num_walls()
		cell.m_Pts.push_back(pcell.m_Pts[pwall2])
		cell.m_Pts.push_back(pcell.m_Pts[parent_wall])
		cell.m_Angles.push_back(pcell.m_Angles[parent_wall] + PI)
		cell.m_LinkedCells.push_back(parent_cell)
		cell.m_bLinkAllowed.push_back(false)
		
		
	
	var plane = CalculatePlane(cell.m_Pts[0], cell.m_Pts[1])
	cell.m_Planes.push_back(plane)


	var rtype : int = randi() % 3
	#var rtype : int = 2
	match rtype:
		0:
			MakeRoom_Generic(cell)
		1:
			MakeRoom_Corridor(cell)
		2:
			MakeRoom_Poly(cell)
	
	if Graph.Cell_TestCollisions(cell, parent_cell) == false:
		# revert any links?
		return
	
	# make back link to parent
	if parent_cell != -1:
		var pcell : Graph.GCell = Graph.m_Level.m_Cells[parent_cell]
		pcell.m_LinkedCells[parent_wall] = new_cell_id
	
	
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
	cell.m_bLinkAllowed.push_back(true)
	cell.m_Planes.push_back(plane)
	
	
	#print("adding wall from " + str(ptLeft) + " to " + str(pt))
	
	return bClosed

func Cell_CreateGeometry(var cell_id, var parent):
	var cell : Graph.GCell = Graph.m_Level.m_Cells[cell_id]
	
	var spatial = Spatial.new()
	parent.add_child(spatial)
	spatial.set_name("room_" + str(cell_id))
	cell.node = spatial
	
	Cell_CreateGeometry_Walls(cell, spatial)
	Cell_CreateGeometry_Portals(cell, spatial)
	Cell_CreateGeometry_Floors(cell, spatial)
	
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

	var nWalls : int = cell.m_Pts.size()
	for w in nWalls:
		var w2 : int = (w + 1) % nWalls
		
		if cell.is_wall_portal(w):
			continue
#			st.set_material(Scene.m_mat_Portal)
#			#st.add_color(color2)
#		else:
#			#st.add_color(color)
#			st.set_material(Scene.m_mat_Wall)
		
		var v0 = GHelp.Vec2ToVec3(cell.m_Pts[w])
		var v1 = GHelp.Vec2ToVec3(cell.m_Pts[w], 2.0)
		var v2 = GHelp.Vec2ToVec3(cell.m_Pts[w2], 2.0)
		var v3 = GHelp.Vec2ToVec3(cell.m_Pts[w2])
		
		var norm = cell.m_Planes[w].normal
		st.add_normal(norm)
		st.add_vertex(v0)
		st.add_normal(norm)
		st.add_vertex(v2)
		st.add_normal(norm)
		st.add_vertex(v1)
		
		st.add_normal(norm)
		st.add_vertex(v0)
		st.add_normal(norm)
		st.add_vertex(v3)
		st.add_normal(norm)
		st.add_vertex(v2)
		
	st.commit(tmpMesh)

	mi_walls.mesh = tmpMesh


func Cell_CreateGeometry_Portals(var cell : Graph.GCell, var spatial : Spatial):
	
	var mi_walls = MeshInstance.new()
	spatial.add_child(mi_walls)
	mi_walls.set_name("portals")
	
	var mesh = mi_walls.mesh
	
	var tmpMesh = Mesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(Scene.m_mat_Portal)

	var nWalls : int = cell.m_Pts.size()
	for w in nWalls:
		var w2 : int = (w + 1) % nWalls
		
		if cell.is_wall_portal(w) == false:
			continue
		
		var v0 = GHelp.Vec2ToVec3(cell.m_Pts[w])
		var v1 = GHelp.Vec2ToVec3(cell.m_Pts[w], 2.0)
		var v2 = GHelp.Vec2ToVec3(cell.m_Pts[w2], 2.0)
		var v3 = GHelp.Vec2ToVec3(cell.m_Pts[w2])
		
		var norm = cell.m_Planes[w].normal
		st.add_normal(norm)
		st.add_vertex(v0)
		st.add_normal(norm)
		st.add_vertex(v2)
		st.add_normal(norm)
		st.add_vertex(v1)
		
		st.add_normal(norm)
		st.add_vertex(v0)
		st.add_normal(norm)
		st.add_vertex(v3)
		st.add_normal(norm)
		st.add_vertex(v2)
		
	st.commit(tmpMesh)

	mi_walls.mesh = tmpMesh

func Cell_CreateGeometry_Floors(var cell : Graph.GCell, var spatial : Spatial):
	
	var mi_walls = MeshInstance.new()
	spatial.add_child(mi_walls)
	mi_walls.set_name("floors")
	
	var mesh = mi_walls.mesh
	
	var tmpMesh = Mesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(Scene.m_mat_Floor)

	var nWalls : int = cell.m_Pts.size()
	for w in nWalls:
		var w2 : int = (w + 1) % nWalls
		
		#if cell.is_wall_portal(w) == false:
		#	continue
		
		var v0 = GHelp.Vec2ToVec3(cell.m_Pts[0])
		var v1 = GHelp.Vec2ToVec3(cell.m_Pts[w])
		var v2 = GHelp.Vec2ToVec3(cell.m_Pts[w2])
		
		var norm = Vector3(0, 1, 0)
		st.add_normal(norm)
		st.add_vertex(v0)
		st.add_normal(norm)
		st.add_vertex(v1)
		st.add_normal(norm)
		st.add_vertex(v2)
		
		
	st.commit(tmpMesh)

	mi_walls.mesh = tmpMesh
