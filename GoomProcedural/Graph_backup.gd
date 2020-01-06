extends Node

var id_counter : int = 0
var iteration_counter : int = 0
var m_ImmGeom : ImmediateGeometry

class GWall:
	var id : int = 0
	var ptLeft_local : Vector2 = Vector2()
	var ptRight_local : Vector2 = Vector2()
	var ptLeft_world : Vector2 = Vector2()
	var ptRight_world : Vector2 = Vector2()
	
	var ptCentre_local : Vector2 = Vector2()
	var ptCentre_world : Vector2 = Vector2()
	var size : float = 1.0

	var bPortal = false
	var linked_id : int = -1
	var linked_dist : float = 1000000.0
	
	func ptLeft_local3():
		return Vector3(ptLeft_local.x, 0, ptLeft_local.y)
	func ptRight_local3():
		return Vector3(ptRight_local.x, 0, ptRight_local.y)
	func ptTop_local3():
		return Vector3(ptLeft_local.x, 1, ptLeft_local.y)
	
	
	func ptBotLeft():
		return Vector3(ptLeft_local.x, 0, ptLeft_local.y)
	func ptBotRight():
		return Vector3(ptRight_local.x, 0, ptRight_local.y)
	func ptTopLeft():
		return Vector3(ptLeft_local.x, 2, ptLeft_local.y)
	func ptTopRight():
		return Vector3(ptRight_local.x, 2, ptRight_local.y)
	
	func update_world_pos(var cell : GCell):
		ptCentre_world = cell.xform_point(ptCentre_local)
		ptLeft_world = cell.xform_point(ptLeft_local)
		ptRight_world = cell.xform_point(ptRight_local)
		
		calculate_world_plane()
		
		if bPortal:
			cell.indicator.translation = Vector3(ptCentre_world.x, 0, ptCentre_world.y)

	func calculate_world_plane():
		plane_world = Plane(GHelp.Vec2ToVec3(ptRight_world), GHelp.Vec2ToVec3(ptRight_world, 1.0), GHelp.Vec2ToVec3(ptLeft_world))
		
	
	func calculate_local_plane():
		plane_local = Plane(ptRight_local3(), ptTop_local3(), ptLeft_local3())
	
	func debug_string():
		var sz = ""
		sz += "from " + str(ptLeft_local)
		sz += "\tto " + str(ptRight_local)
		sz += "\tangle " + str(rad2deg(angle))
		sz += "\tplane " + str(plane_local)
		return sz
	
	var angle : float # from north in local space
	var plane_local : Plane = Plane()
	var plane_world : Plane = Plane()

class GCell:
	var walls = []
	var rot : float
	var pos : Vector2 = Vector2()
	var node : Spatial
	var indicator : Spatial
	var aabb : Rect2
	
	func xform_point(var pt : Vector2)->Vector2:
		var basis = Basis(Vector3(0, 1, 0), rot)
		var ptRot = basis.xform(Vector3(pt.x, 0, pt.y))
		return Vector2(ptRot.x, ptRot.z) + pos

	
	func update_world(var new_pos, var new_rot):
		pos = new_pos
		rot = new_rot
		
		if walls.size() <= 0:
			return
		
		#aabb = Rect2(walls[0].ptLeft_world, Vector2(0, 0))
		
		# calculate wall positions world space
		for w in range (walls.size()):
			var wall : GWall = walls[w]
			wall.update_world_pos(self)
			
			if w != 0:
				aabb = aabb.expand(wall.ptLeft_world)
			else:
				aabb = Rect2(wall.ptLeft_world, Vector2(0, 0))
				
			#aabb.expand(walls[w].ptLeft_world)
		
	
	
	
class GLevel:
	var cells = []


var m_Level : GLevel = GLevel.new()


func Cell_CreateGeometry(var cell_id, var parent):
	var cell : GCell = m_Level.cells[cell_id]
	var mesh_instance = MeshInstance.new()
	parent.add_child(mesh_instance)
	mesh_instance.set_name("cell_" + str(cell_id))
	cell.node = mesh_instance
	
	var mesh = mesh_instance.mesh
	
	var tmpMesh = Mesh.new()
	
	var mat = SpatialMaterial.new()
	var color = Color(0.1, 0.8, 0.1)
	#mat.albedo_color = color
	mat.params_cull_mode = SpatialMaterial.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	
	var mat2 = SpatialMaterial.new()
	var color2 = Color(0.8, 0.1, 0.1)
	mat2.albedo_color = color2
	mat2.params_cull_mode = SpatialMaterial.CULL_DISABLED

	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)

	for w in cell.walls.size():
		var wall : GWall = cell.walls[w]
		
		if wall.bPortal:
			st.add_color(color2)
		else:
			st.add_color(color)
		
		var v0 = wall.ptBotLeft()
		var v1 = wall.ptTopLeft()
		var v2 = wall.ptTopRight()
		var v3 = wall.ptBotRight()
		
		var norm = wall.plane_local.normal
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
		
		
#	for v in m_Unique_Verts.size():
#		var vt : obj_vert = m_Unique_Verts[v]
#
#		if m_Norms.size():
#			st.add_normal(vt.m_Norm)
##		#st.add_normal(smoothed_norms[v])
##		#st.add_color(color)
#		if m_UVs.size():
#			st.add_uv(vt.m_UV)
#			if bToUV2:
#				st.add_uv2(vt.m_UV)
#
#		st.add_vertex(vt.m_Pos)

	# indices
#	for i in m_Unique_Tris.size():
#		st.add_index(m_Unique_Tris[i])
		

	st.commit(tmpMesh)

	mesh_instance.mesh = tmpMesh
	
	var indic = Scene.m_scene_Indicator.instance()
	parent.add_child(indic)
	
	cell.indicator = indic
	
	pass


func Cell_Create():
	var cell = GCell.new()
	cell.pos.x = -60 + (m_Level.cells.size() * 20)
	
	var bComplete = false
	
	while (bComplete == false):
		bComplete = Cell_AddWall(cell)
		
	# centralize .. rejig the walls to the centre
	var ptCentre = Vector2(0, 0)
	for w in range (cell.walls.size()):
		var wall : GWall = cell.walls[w]
		ptCentre += wall.ptLeft_local
	
	# get the centre and move the walls to this	
	ptCentre /= cell.walls.size()
	
	for w in range (cell.walls.size()):
		var wall : GWall = cell.walls[w]
		wall.ptLeft_local -= ptCentre
		wall.ptRight_local -= ptCentre
		wall.calculate_local_plane()
		wall.ptCentre_local = (wall.ptLeft_local + wall.ptRight_local) / 2
		wall.ptCentre_world = wall.ptCentre_local
		wall.size = (wall.ptRight_local - wall.ptLeft_local).length()
		
	# choose which walls will be portals
	var max_portals = cell.walls.size()
	if max_portals > 3:
		max_portals = 3
	
	var nPortals = randi() % max_portals
	if nPortals <= 1:
		nPortals = 2
		
	for p in range (nPortals):
		while (true):
			if Cell_ChoosePortal(cell) == true:
				break
	
	m_Level.cells.push_back(cell)

func Cell_ChoosePortal(var cell : GCell):
	var w = randi() % cell.walls.size()
	var wall : GWall = cell.walls[w]
	if wall.bPortal == true:
		return false
	wall.bPortal = true
	return true
	
func Cell_Link(var cell_id_from : int, var cell_id_to : int):
	var cfrom : GCell = m_Level.cells[cell_id_from]
	var cto : GCell = m_Level.cells[cell_id_to]
	
	var wfrom : int = FindFreePortal(cfrom)
	var wto : int = FindFreePortal(cto)
	
	var wall_from = cfrom.walls[wfrom]
	var wall_to = cto.walls[wto]
	
	wall_from.linked_id = wall_to.id
	wall_to.linked_id = wall_from.id
	

func FindFreePortal(var cell : GCell)->int:
	for w in range (cell.walls.size()):
		var wall : GWall = cell.walls[w]
		if (wall.bPortal == true) and (wall.linked_id == -1):
			return w
			
	return -1

func Cell_AddWall(var cell : GCell):
	var wall = GWall.new()
	
	# keep a unique id for each wall
	wall.id = id_counter
	id_counter += 1
	
	var bClosed : bool = false
	
	wall.ptLeft_local = Vector2(0, 0)
	
	var bFirstWall = cell.walls.size() == 0
	
	# if there is a wall already, the left point of the new wall is the right of the previous
	if bFirstWall == false:
		var wall_prev : GWall = cell.walls[cell.walls.size()-1]
		wall.ptLeft_local = wall_prev.ptRight_local
		wall.angle = wall_prev.angle
	
	wall.angle += GHelp.Rand_Angle()
	if (wall.angle > (2 * PI)):
		wall.angle -= (2 * PI)
	
	var dist : float = rand_range(2.0, 8.0)

	wall.ptRight_local = wall.ptLeft_local + (GHelp.AngleToVector(wall.angle) * dist)	

	# calculate plane first time	
	wall.calculate_local_plane()
	
	# detect situation where we must close the cell to remain convex
	# and override this new wall
	if bFirstWall == false:
		var wall_first : GWall = cell.walls[0]
		
		var bClose = false
		
		if wall_first.plane_local.distance_to(wall.ptRight_local3()) > -0.5:
			bClose = true
			
		# if the start point is in front of the plane, we are folding in on ourself so will close
		# i.e. going for a second loop
		if wall.plane_local.distance_to(Vector3(0, 0, 0)) > 0.0:
			bClose = true
			
		if bClose:
			# conditions to close
			bClosed = true
			wall.angle = GHelp.VectorToAngle(wall.ptLeft_local)
			wall.ptRight_local = Vector2(0, 0)
			# calculate the plane again
			wall.calculate_local_plane()
	
	#if (randi() % 10) <= 2:
	#	wall.bPortal = true
	
	
	# add the wall
	cell.walls.push_back(wall)
	
	print("adding wall " + wall.debug_string())
	
	return bClosed


func Create(var parent):
	var ang = GHelp.VectorToAngle(Vector2(1, 1))
	var vec = GHelp.AngleToVector(ang)
	
	var nCells = 10
	
	for c in range (nCells):
		Cell_Create()
		
	for c in range (nCells):
		Cell_Link(c, (c+1) % nCells)
	
	
	for c in range (m_Level.cells.size()):
		Cell_CreateGeometry(c, parent)
		
	#for c in range (1):
	#	Iterate()
	pass


func Iterate(var imm_geom : ImmediateGeometry):
	m_ImmGeom = imm_geom
	m_ImmGeom.clear()
	m_ImmGeom.begin(Mesh.PRIMITIVE_LINES)
	
	for c in range (m_Level.cells.size()):
		Iterate_Cell(c)
		
	m_ImmGeom.end()
		
	iteration_counter += 1
	pass

func Iterate_Cell(var cell_id : int):
	var cell : GCell = m_Level.cells[cell_id]
	
	var force : Vector2 = Vector2(0, 0)
	var angle_push : float = 0.0
	
	for w in range (cell.walls.size()):
		var wall : GWall = cell.walls[w]
		force += Iterate_CellWall(cell_id, wall)
		angle_push += Iterate_FindAnglePush(cell_id, force, wall)
		
		
	Iterate_MoveCell(cell_id, force, angle_push)
		
	pass
	
func Iterate_CellWall(var cell_id : int, var wall : GWall) -> Vector2:

	var force : Vector2 = Vector2(0, 0)
	
	# find forces from each other cell
	for c in range (m_Level.cells.size()):
		if c != cell_id:
			var ncell : GCell = m_Level.cells[c]
			
			for w in range (ncell.walls.size()):
				force += Iterate_FindForce(wall, ncell.walls[w])

	return force


func Iterate_FindAnglePush(var cell_id : int, var force : Vector2, var wall : GWall)->float:
	var cell : GCell = m_Level.cells[cell_id]
	
	# pt of impact in worldspace relative to centre
	var ptImpact = wall.ptCentre_world - cell.pos
	
	var angle_push : float = ptImpact.cross(force)
	
	return angle_push * -0.01

#func Iterate_MoveCell(var cell_id : int, var force : Vector2, var wall : GWall):
func Iterate_MoveCell(var cell_id : int, var force : Vector2, var angle_push : float):
	var cell : GCell = m_Level.cells[cell_id]
	
	# global position
	var new_pos : Vector2 = cell.pos + force
	var new_rot : float = cell.rot + angle_push
	
	# test if it is okay?
	if Iterate_TestMove(cell_id, new_pos, new_rot) == false:
		return
	
	cell.node.translation.x = cell.pos.x
	cell.node.translation.z = cell.pos.y
	
	cell.node.rotation = Vector3(0, cell.rot, 0)
	
	
	pass
	
func Iterate_TestMove(var cell_id : int, var new_pos : Vector2, var new_rot : float):
	var cell : GCell = m_Level.cells[cell_id]
	
	# to test the move we will calculate the new wall planes
	var old_pos = cell.pos
	var old_rot = cell.rot

	cell.update_world(new_pos, new_rot)	

	# test
	var bPassed = true
	
	# is any corner of any other cell now within the test cell? if so, abort move
	# this is expensive
	for c in range (m_Level.cells.size()):
		if c == cell_id:
			continue # dont test against ourself
			
		var ncell : GCell = m_Level.cells[c]
		
		if cell.aabb.intersects(ncell.aabb) == false:
			continue
		
		for nw in range (ncell.walls.size()):
			var nwall : GWall = ncell.walls[nw]
		
			var bOutside = false
			for w in range (cell.walls.size()):
				var wall : GWall = cell.walls[w]
				var dist : float = wall.plane_world.distance_to(GHelp.Vec2ToVec3(nwall.ptLeft_world))
				if dist > 0.0:
					# in front of any plane is outside
					bOutside = true
					break

			if bOutside == false:
				# collision!! we need to revert		
				cell.update_world(old_pos, old_rot)
				return false
	
	# revert
	#if bPassed == false:
	#	cell.update_world(old_pos, old_rot)
	
	
	return bPassed
	

const MAX_FORCE_DIST = 10.0
const MAX_FORCE_DIST_ATTRACT = 400.0
	
func Iterate_FindForce(var wall : GWall, var nwall : GWall):
	var diff : Vector2 = nwall.ptCentre_world - wall.ptCentre_world
	var l : float = diff.length()
	
	var bAttract = false
	if (wall.bPortal == true) and (nwall.bPortal == true):
		bAttract = true
	#else:
	#	return Vector2(0, 0)
			


	# if attracting, is another linked and closer?
	if bAttract:
		if (wall.linked_id == -1) and (nwall.linked_id == -1):
		#if wall.linked_id != nwall.id:
			# takeover?
			#if l > wall.linked_dist:
				#return Vector2(0, 0)
		
			# taking over
			wall.linked_id = nwall.id
			nwall.linked_id = wall.id
			wall.linked_dist = l
			nwall.linked_dist = l
		else:
			if wall.linked_id != nwall.id:
			# takeover?
			#if l > wall.linked_dist:
				return Vector2(0, 0)
			else:
				m_ImmGeom.add_vertex(GHelp.Vec2ToVec3(wall.ptCentre_world))
				m_ImmGeom.add_vertex(GHelp.Vec2ToVec3(nwall.ptCentre_world))


	var max_dist : float = MAX_FORCE_DIST
	
	if bAttract:
		max_dist = MAX_FORCE_DIST_ATTRACT
	
	var mag : float = max_dist - l
	
	if mag <= 0.0:
		return Vector2(0, 0)

	mag /= max_dist
	
	#mag = 1.0 - mag
	#mag *= mag
	#mag = 1.0 - mag

	diff = diff.normalized()
	
	# attract, else repel
	if bAttract == false:
		mag *= -1.0
	else:
		mag *= 1.0
		
	mag *= 0.1
	
	return diff * mag

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
