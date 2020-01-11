extends Node

var m_Objects = []

class GObject:
	var m_SID : int = -1
	var m_ptPos : Vector3
	var m_ptVel : Vector3


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
	
	slide_move(o)
	
#	o.m_ptPos += o.m_ptVel
#
#	#if o.m_SID == -1:
#	var sid = Graph.find_sector(o.m_ptPos)
#	if sid != o.m_SID:
#		o.m_SID = sid
#		print("entering sector " + str(o.m_SID))
	
	
	o.m_ptVel *= 0.95 # friction

func iterate_all():
	var nItems = m_Objects.size()
	
	for n in range (nItems):
		iterate_obj(n)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func slide_move(var o : GObject, var count : int = 0):
	var pt : Vector3 = o.m_ptPos + o.m_ptVel
	
	# special case of no existing sector
	if o.m_SID == -1:
		o.m_SID = Graph.find_sector(pt)
		o.m_ptPos = pt
		return
	
	var sid : int = o.m_SID
	
	var s : Graph.GSector = Graph.m_Sectors[sid]

	for w in range (s.m_NumWalls):
		var wid = w + s.m_FirstWall
		var plane : Plane = Graph.m_Planes[wid]
		var dist = plane.distance_to(pt)
		if dist > 0.0:
			# slide
			o.m_ptVel = o.m_ptVel.slide(plane.normal)
			if count <= 4:
				slide_move(o, count + 1)
			return

	var plane_floor : Plane = Graph.m_FloorPlanes[sid]
	var fdist = plane_floor.distance_to(pt)
	if fdist < 0.0:
		# slide
		o.m_ptVel = o.m_ptVel.slide(plane_floor.normal)
		if count <= 4:
			slide_move(o, count + 1)
		return

	var plane_ceil = Graph.m_CeilPlanes[sid]
	var cdist = plane_ceil.distance_to(pt)
	if fdist < 0.0:
		# slide
		o.m_ptVel = o.m_ptVel.slide(plane_ceil.normal)
		if count <= 4:
			slide_move(o, count + 1)
		return
	
	o.m_ptPos = pt
