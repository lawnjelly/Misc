extends Node

var m_Objects = []

class GObject:
	var m_SID : int = -1
	var m_ptPos : Vector3
	var m_ptVel : Vector3
	var m_bOnFloor : bool = false


func _ready():
	pass # Replace with function body.


func create_obj()->int:
	var id = m_Objects.size()
	var o = GObject.new()
	o.m_SID = -1
	m_Objects.push_back(o)
	return id
	
func get_obj(var id : int)->GObject:
	return m_Objects[id]

func clear():
	m_Objects.clear()	
	
	
func push(var id : int, var ptVel):
	get_obj(id).m_ptVel += ptVel

func get_pos(var id : int)->Vector3:
	return get_obj(id).m_ptPos
	
	
	
func iterate_obj(var id : int):
	var o : GObject = get_obj(id)
	
	o.m_bOnFloor = false
	slide_move(o)
	
#	o.m_ptPos += o.m_ptVel
#
#	#if o.m_SID == -1:
#	var sid = Graph.find_sector(o.m_ptPos)
#	if sid != o.m_SID:
#		o.m_SID = sid
#		print("entering sector " + str(o.m_SID))
	
	# gravity
	if not o.m_bOnFloor:
		if not Game.m_bPlayer_Flying:
			o.m_ptVel.y -= 0.002
		else:
			o.m_ptVel.y *= 0.95
		
	o.m_ptVel.x *= 0.95 # friction
	o.m_ptVel.z *= 0.95 # friction

func iterate_all():
	var nItems = m_Objects.size()
	
	for n in range (nItems):
		iterate_obj(n)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# this is a safer routine to allow object to skim slide at an exact
# specified distance from the plane, without penetrating the plane
#func safe_slide(var ptNew: Vector3, var o : GObject, var p : Plane, var dist : float):
func safe_slide(var o : GObject, var norm : Vector3, var dist_from_plane, var desired_dist):

	# extra push to get out to desired distance
	var overlap = desired_dist - dist_from_plane
	var push = (overlap / desired_dist) * 0.001
	
	# cap
	push = clamp(push, 0.0, 0.005)

	var dot = o.m_ptVel.dot(norm)
	
	var res : bool = false
	
	if dot < 0.0:
	#if dot < push:
		
		var temp = o.m_ptVel.cross(norm)
		var dir = norm.cross(temp)
		o.m_ptVel = dir
		
		res = true

	if push > 0.0:
		# add push AFTER cross
		o.m_ptVel += (norm * push)
		

	return res
	# find the hit point on the plane surface that corresponds to this point
	# note this assumes ptNew is within normal length
	# from interpenetrating the surface
#	var ptAbove = ptNew + p.normal
#	var ptIntersection = p.intersects_ray(ptAbove, -p.normal)
#
#	# now offset the intersection point up
#	ptIntersection += (dist * p.normal)
#
#	# prevent increase in speed
#	var speed : float = o.m_ptVel.length()
#
#	# now back calculate velocity to this destination
#	o.m_ptVel = ptIntersection - o.m_ptPos
#
#	var new_speed : float = o.m_ptVel.length()
#	if new_speed > speed:
#		o.m_ptVel *= speed / new_speed
	
func slide_move(var o : GObject, var count : int = 0):
	var pt : Vector3 = o.m_ptPos + o.m_ptVel
	
	# special case of no existing sector
	if o.m_SID == -1:
		o.m_SID = Graph.find_sector(pt)
		o.m_ptPos = pt
		return
	
	# how close we can get to planes (radius of object)
	var proximity = 0.5
	
	var sid : int = o.m_SID
	
	var s : Graph.GSector = Graph.m_Sectors[sid]

	for w in range (s.m_NumWalls):
		var wid = w + s.m_FirstWall
		
		var plane : Plane = Graph.m_Planes[wid]
		var dist = plane.distance_to(pt)
		
		if dist < proximity:
			# portal
			var bSlide = true
			
			var nsid : int = Graph.m_LinkedSectors[wid]
			if nsid != -1:
				# what is the height of the opening
				var nwid : int = Graph.m_LinkedWalls[wid]
				var heights : Vector2 = Graph.m_WallHeights[nwid]
				
				# within the opening?
				if (pt.y >= heights.x) and (pt.y <= heights.y):
					if (dist < 0.0):
						# crossing portal
						o.m_SID = nsid
						#Scene.m_node_Root.get_node("Cube").translation = Graph.m_SectorCentres[o.m_SID]
						slide_move(o, count + 1)
						return
						
					bSlide = false
					
			if bSlide:
				# slide
				if safe_slide(o, plane.normal, dist, proximity):
					if count <= 4:
						slide_move(o, count + 1)
					return

	var plane_floor : Plane = Graph.m_FloorPlanes[sid]
	var fdist = plane_floor.distance_to(pt)
	
	if fdist < (proximity + 0.1):
		o.m_bOnFloor = true
		if (fdist < proximity):
			if (safe_slide(o, plane_floor.normal, fdist, proximity)):
				if count <= 4:
					slide_move(o, count + 1)
				return

	var plane_ceil = Graph.m_CeilPlanes[sid]
	var cdist = plane_ceil.distance_to(pt)
	if (cdist < proximity) and (safe_slide(o, plane_ceil.normal, cdist, proximity)):
		if count <= 4:
			slide_move(o, count + 1)
		return
	
	o.m_ptPos = pt

# return floor and ceiling in vector2
func get_linked_wall_heights(var wid : int)->Vector2:
	return Graph.m_WallHeights[wid]
#	var res : Vector2 = Vector2()
#	var inter_floor = Graph.m_FloorPlanes[sid].intersects_ray(Vector3(pos.x, 1000.0, pos.y), Vector3(0, -1, 0))
#	res.x = inter_floor.y
#
#	var inter_ceil = Graph.m_CeilPlanes[sid].intersects_ray(Vector3(pos.x, -1000.0, pos.y), Vector3(0, 1, 0))
#	res.y = inter_ceil.y
#
#	return res
