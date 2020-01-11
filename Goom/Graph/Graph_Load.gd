extends Node

enum eExpecting {
	EX_DEFAULT,
	EX_POINTS,
	EX_PLANES,
	EX_LINKS,
}

var m_File
var m_Line

# line pointer .. strings don't have pointers
var m_LP
var m_LineLength
var m_CurrSectID

var m_Expecting = eExpecting.EX_DEFAULT
var m_bError = false
var m_bVerbose = false

func is_EOL():
	return m_LP >= m_LineLength

func debug_print(var sz):
	if m_bVerbose:
		print(sz)

func read_token():
	var sz = ""
	var bBreak = false
	while bBreak == false:
		if m_LP >= m_LineLength:
			break
			
		var c = m_Line[m_LP]
		m_LP += 1
		
		# end of token?
		match c:
			" ":
				bBreak = true
			"\n":
				bBreak = true
			",":
				m_LP += 1 # trailing space
				bBreak = true
			_:
				# add character to the string
				sz += c
	
	if sz == "":
		print("warning : token is missing")	
	return sz

func read_f():
	var sz = read_token()
	return float(sz)

func read_i():
	var sz = read_token()
	return int (sz)

func read_plane()->Plane:
	var p = Plane()
	p.x = read_f()
	p.y = read_f()
	p.z = read_f()
	p.d = read_f()
	return p

func read_vec2()->Vector2:
	var v = Vector2()
	v.x = read_f()
	v.y = read_f()
	return v

func error(var sz : String):
	m_bError = true
	print ("lev import error : " + sz)

func get_curr_sector()->Graph.GSector:
	return Graph.m_Sectors[m_CurrSectID]


func import(var filename):
	Graph.clear()
	m_Expecting = eExpecting.EX_DEFAULT
	m_Line = ""
	m_LP = 0
	m_LineLength = 0
	m_bError = false
	
	m_File = File.new()
	var err = m_File.open(filename, File.READ)
	if err != OK:
		return false
	
	while m_File.eof_reached() == false:
		m_Line = m_File.get_line()
		m_LineLength = m_Line.length()
		m_LP = 0
		process_line()
	
	m_File.close()
	return true

func process_line():
	# empty line
	if m_LineLength == 0:
		return
	
	# comment
	if m_Line.substr(0, 1) == "#":
		return
	
	# eat tabs
	while m_Line[m_LP] == "\t":
		m_LP += 1
		if is_EOL():
			return
	
	match m_Expecting:
		eExpecting.EX_DEFAULT:
			process_default()
		eExpecting.EX_POINTS:
			process_points()
			m_Expecting = eExpecting.EX_DEFAULT
		eExpecting.EX_PLANES:
			process_planes()
			m_Expecting = eExpecting.EX_DEFAULT
		eExpecting.EX_LINKS:
			process_links()
			m_Expecting = eExpecting.EX_DEFAULT
	
	
func process_links():
	var num_walls = get_curr_sector().m_NumWalls
	for w in range (num_walls):
		var link_id : int = read_i()
		Graph.m_LinkedSectors.push_back(link_id)
		debug_print("linked_sector " + str(link_id))

func process_planes():
	var num_walls = get_curr_sector().m_NumWalls
	for w in range (num_walls):
		var pl : Plane = read_plane()
		Graph.m_Planes.push_back(pl)
		debug_print("plane " + str(pl))

func process_points():
	var num_walls = get_curr_sector().m_NumWalls
	for w in range (num_walls):
		var pt : Vector2 = read_vec2()
		Graph.m_Pts.push_back(pt)
		debug_print("point " + str(pt))
		

func process_default():
	var sz = read_token()
	
	if sz == "num_sectors":
		Graph.m_NumSectors = read_i()
		return
		
	if sz == "sector":
		var sid = read_i()
		if (sid != Graph.m_Sectors.size()):
			error("sector ID is incorrect")
			return
		m_CurrSectID = Graph.m_Sectors.size()
		debug_print("sector " + str(m_CurrSectID))
		Graph.m_Sectors.push_back(Graph.GSector.new())
		get_curr_sector().m_FirstWall = Graph.m_Pts.size()
		debug_print("firstwall " + str(get_curr_sector().m_FirstWall))
		return
			
	if sz == "num_walls":
		get_curr_sector().m_NumWalls = read_i()
		debug_print("numwalls " + str(get_curr_sector().m_NumWalls))
		return
		
	if sz == "points":
		m_Expecting = eExpecting.EX_POINTS
		return

	if sz == "planes":
		m_Expecting = eExpecting.EX_PLANES
		return

	if sz == "links":
		m_Expecting = eExpecting.EX_LINKS
		return

	if sz == "floor":
		var pl = read_plane()
		debug_print("floorplane " + str(pl))
		Graph.m_FloorPlanes.push_back(pl)
		return

	if sz == "ceil":
		var pl = read_plane()
		debug_print("ceilplane " + str(pl))
		Graph.m_CeilPlanes.push_back(pl)
		return
