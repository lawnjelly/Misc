extends Node


class DukeMap:
	var mapversion : int
	var posx : int
	var posy : int
	var posz : int
	var angle : int
	var curr_sect_num : int
	var num_sectors : int
	var num_walls : int
	var num_sprites : int
	
	var sectors = []
	var walls = []
	var sprites = []

class DukeSurf:
	var picnum : int
	var heinum : int
	var shade : int
	var pal : int
	var xpan : int
	var ypan : int
	

class DukeSector:
	var wallptr : int
	var wallnum : int
	var ceilingz : int
	var floorz : int
	var ceilingstat : int
	var floorstat : int
	
	var _ceiling : DukeSurf
	var _floor : DukeSurf
	
#	var ceilingpicnum : int
#	var ceilingheinum : int
#	var ceilingshade : int
#	var ceilingpal : int
#	var ceilingxpan : int
#	var ceilingypan : int
#
#	var floorpicnum : int
#	var floorheinum : int
#	var floorshade : int
#	var floorpal : int
#	var floorxpan : int
#	var floorypan : int
	
	var visibility : int
	var filler : int
	var lotag : int
	var hitag : int
	var extra : int


class DukeWall:
	var x : int
	var y : int
	var point2 : int
	var nextwall : int
	var nextsector : int
	var cstat : int
	var picnum : int
	var overpicnum : int
	var shade : int
	var pal : int
	var xrepeat : int
	var yrepeat : int
	var xpanning : int
	var ypanning : int
	var lotag : int
	var hitag : int
	var extra : int
	
	func IsBlocking():
		return cstat & 113


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var m_File

# duke map
var m_Map : DukeMap = DukeMap.new()

var m_Scale : float = (1.0 / 512.0) * 0.1
var m_Scale_Height : float = (1.0/(512.0*16.0)) * 0.1
var m_Scale_Angle : float = 1.0/4096.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_u8()->int:
	return m_File.get_8()
	
func get_u16()->int:
	return m_File.get_16()
	
func get_u32()->int:
	return m_File.get_32()
	
func get_i8()->int:
	var i = get_u8()
	if i > 127:
		i = 256 - i
		i = -i
	return i

func get_i16()->int:
	var i = get_u16()
	if i > 32767:
		i = 65536 - i
		i = -i
	return i

func get_i32()->int:
	var i = get_u32()
	if i > 2147483647:
		i = 4294967296 - i
		i = -i
	return i



func duke_import(filename, parent):
	import(filename)
	
	# convert
	for s in range (m_Map.num_sectors):
		convert_sector(parent, s)


func convert_sector(parent, sec_num):
	var se : DukeSector = m_Map.sectors[sec_num]
	
	var room : Spatial = Spatial.new()
	room.set_name("room_" + str(sec_num))
	parent.add_child(room)
	
	# walls
	for w in range (se.wallnum):
		convert_wall(room, se, se.wallptr + w)


func convert_wall(room : Spatial, sector : DukeSector, wall_num : int):
	var wall : DukeWall = m_Map.walls[wall_num]
	assert (wall.point2 < m_Map.num_walls)
	var wall2 : DukeWall = m_Map.walls[wall.point2]
	
	if wall.IsBlocking() == 0:
		return
	
	var mi : MeshInstance = MeshInstance.new()
	room.add_child(mi)
	
	var tmpMesh = Mesh.new()
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#st.set_material(mat)

	var pt1 : Vector2 = Vector2(wall.x * m_Scale, wall.y * m_Scale)
	var pt2 : Vector2 = Vector2(wall2.x * m_Scale, wall2.y * m_Scale)

	var h1 = sector.floorz * m_Scale_Height
	var h2 = sector.ceilingz * m_Scale_Height
#	var h1 = 0
#	var h2 = 2


	var vts = []
	vts.push_back(Vector3(pt1.x, h1, pt1.y))
	vts.push_back(Vector3(pt1.x, h2, pt1.y))
	vts.push_back(Vector3(pt2.x, h2, pt2.y))
	vts.push_back(Vector3(pt2.x, h1, pt2.y))

	# calculate normal
	var diff : Vector2 = pt2 - pt1
	var norm : Vector3 = Vector3(-diff.y, 0, -diff.x)
	norm = norm.normalized()

	
	for v in vts.size():
		
		#if m_Norms.size():
		#	st.add_normal(vt.m_Norm)
#		#st.add_normal(smoothed_norms[v])
#		#st.add_color(color)
		#if m_UVs.size():
		#	st.add_uv(vt.m_UV)
		#	if bToUV2:
		#		st.add_uv2(vt.m_UV)

		st.add_normal(norm)				
		st.add_vertex(vts[v])

	# indices
#	for i in m_Unique_Tris.size():
#		st.add_index(m_Unique_Tris[i])
	st.add_index(0)
	st.add_index(1)
	st.add_index(2)
	st.add_index(0)
	st.add_index(2)
	st.add_index(3)
		

	st.commit(tmpMesh)

	mi.mesh = tmpMesh
	

# http://www.shikadi.net/moddingwiki/MAP_Format_(Build)
func import(filename):
	
	m_File = File.new()
	var err = m_File.open(filename, File.READ)
	if err != OK:
		return false
		
		
	m_Map.mapversion = get_i32()
	m_Map.posx = get_i32()
	m_Map.posy = get_i32()
	m_Map.posz = get_i32()
	m_Map.angle = get_i16()
	m_Map.curr_sect_num = get_i16()
	m_Map.num_sectors = get_u16()
	
	print ("num_sectors " + str(m_Map.num_sectors))
	
	for s in range (m_Map.num_sectors):
		read_sector(s)
	
	m_Map.num_walls = m_File.get_16()
	
	for w in range (m_Map.num_walls):
		read_wall(w)

	m_Map.num_sprites = m_File.get_16()
	
	for s in range (m_Map.num_sprites):
		read_sprite(s)
	
	m_File.close()
	return true

class DukeSprite:
	var x : int
	var y : int
	var z : int
	var cstat : int
	var picnum : int
	var shade : int
	var pal : int
	var clipdist : int
	var filler : int
	var xrepeat : int
	var yrepeat : int
	var xoffset : int
	var yoffset : int
	var sectnum : int
	var statnum : int
	var ang : int
	var owner : int
	var xvel : int
	var yvel : int
	var zvel : int
	var lotag : int
	var hitag : int
	var extra : int

func read_sprite(sprite_num):
	print ("sprite " + str(sprite_num))

	var sp : DukeSprite = DukeSprite.new()

	sp.x = get_i32()
	sp.y = get_i32()
	sp.z = get_i32()
	sp.cstat = get_i16()
	sp.picnum = get_i16()
	sp.shade = get_i8()
	sp.pal = get_u8()
	sp.clipdist = get_u8()
	sp.filler = get_u8()
	sp.xrepeat = get_u8()
	sp.yrepeat = get_u8()
	sp.xoffset = get_i8()
	sp.yoffset = get_i8()
	sp.sectnum = get_i16()
	sp.statnum = get_i16()
	sp.ang = get_i16()
	sp.owner = get_i16()
	sp.xvel = get_i16()
	sp.yvel = get_i16()
	sp.zvel = get_i16()
	sp.lotag = get_i16()
	sp.hitag = get_i16()
	sp.extra = get_i16()
	
	m_Map.sprites.push_back(sp)
	
	
	
func read_wall(wall_num):
	
	var dw : DukeWall = DukeWall.new()
	
	dw.x = get_i32()
	dw.y = get_i32()
	dw.point2 = get_i16()
	dw.nextwall = get_i16()
	dw.nextsector = get_i16()
	dw.cstat = get_u16()
	
	dw.picnum = get_i16()
	dw.overpicnum = get_i16()
	
	dw.shade = get_i8()
	
	dw.pal = get_u8()
	dw.xrepeat = get_u8()
	dw.yrepeat = get_u8()
	dw.xpanning = get_u8()
	dw.ypanning = get_u8()
	
	dw.lotag = get_i16()
	dw.hitag = get_i16()
	dw.extra = get_i16()

	m_Map.walls.push_back(dw)

	print ("wall " + str(wall_num) + "\txy : "+ str(dw.x) + ", "+ str(dw.y))

	
func read_surf(var surf : DukeSurf):
	surf = DukeSurf.new()
	surf.picnum = get_i16()
	surf.heinum = get_i16()
	surf.shade = get_i8()
	surf.pal = get_u8()
	surf.xpan = get_u8()
	surf.ypan = get_u8()
	

func read_sector(sect_num):
	print ("sector " + str(sect_num))
	
	var se : DukeSector = DukeSector.new()
	
	se.wallptr = get_i16()
	se.wallnum = get_i16()
	se.ceilingz = get_i32()
	se.floorz = get_i32()
	se.ceilingstat = get_i16()
	se.floorstat = get_i16()

	read_surf(se._ceiling)
	read_surf(se._floor)
	
	se.visibility = get_u8()
	se.filler = get_u8()
	se.lotag = get_i16()
	se.hitag = get_i16()
	se.extra = get_i16()
	
	m_Map.sectors.push_back(se)
	
	print ("\tnumwalls : \t" + str(se.wallnum))
	
	pass
