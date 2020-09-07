extends Reference

class_name LightProbes

var m_File : File
var m_ProbeMap : ProbeMap = ProbeMap.new()
var m_bError : bool = false
var m_bDebugFrame : bool = false

var m_Directional_Distance : float = 15.0

class SampleResult:
	var pos : Vector3
	var power : float
	var color : Color
	var color_indirect : Color


class Vec3i:
	func Set(var xx, var yy, var zz):
		x = xx
		y = yy
		z = zz
	func from(var pt : Vector3):
		x = pt.x
		y = pt.y
		z = pt.z
	func to_string()->String:
		return str(x) + ", "+ str(y) + ", " + str(z)
		
	var x : int
	var y : int
	var z : int

class Octalight:
	var light_id : int
	var powers = [] # 8 powers per octalight

class Octaprobe:
	var indirect_r = []
	var indirect_g = []
	var indirect_b = []
	var lights = []

class Probe:
	var col_indirect : Color = Color()
	var contributions = []

class Contribution:
	var light_id : int
	var power : float

class ProbeMap:
	var voxel_size : Vector3
	var ptMin
	var dims : Vec3i = Vec3i.new()
	var XTimesY : int
	var probes = []
	var lights = []
	var octaprobes = []

class ProbeLight:
	var type : int
	var pos : Vector3
	var dir : Vector3
	var energy : float
	var rang : float
	var color : Color
	var spot_angle_radians : float

#class LightSample:
#	var light_id : int
#	var power : float

func _create_octaprobe(var x, var y, var z):
	var prs = []
	prs.push_back(_get_probe_xyz(x, y, z))
	prs.push_back(_get_probe_xyz(x, y, z+1))
	prs.push_back(_get_probe_xyz(x+1, y, z+1))
	prs.push_back(_get_probe_xyz(x+1, y, z))
	prs.push_back(_get_probe_xyz(x, y+1, z))
	prs.push_back(_get_probe_xyz(x, y+1, z+1))
	prs.push_back(_get_probe_xyz(x+1, y+1, z+1))
	prs.push_back(_get_probe_xyz(x+1, y+1, z))
	
	var octaprobe : Octaprobe = Octaprobe.new()
	
	# first step fill the lights
	for p in range (8):
		var pr : Probe = prs[p]

		# indirect light
		octaprobe.indirect_r.push_back(pr.col_indirect.r)
		octaprobe.indirect_g.push_back(pr.col_indirect.g)
		octaprobe.indirect_b.push_back(pr.col_indirect.b)
		
		# go through contributions
		for n in range (pr.contributions.size()):
			var cont : Contribution = pr.contributions[n]
			
			# is the light id already in the list? if not add it
			var exists = false
	
			for ol in range (octaprobe.lights.size()):
				if (octaprobe.lights[ol].light_id == cont.light_id):
					exists = true
					break
			
			if exists == false:
				var octalight = Octalight.new()
				octalight.light_id = cont.light_id
				octaprobe.lights.push_back(octalight)

	# second step add the values for each corner
	for ol_id in range (octaprobe.lights.size()):
		var ol : Octalight = octaprobe.lights[ol_id]
		var light_id = ol.light_id
		
		for pr_count in range (8):
			var pr : Probe = prs[pr_count]
			
			var power : float = 0.0
			
			# go through contributions
			for n in range (pr.contributions.size()):
				var cont : Contribution = pr.contributions[n]
				
				if cont.light_id == light_id:
					power = 1.0# cont.power
					break
		
			# add the power to that octalight (either specified in the probe, or 0.0 if not specified)
			ol.powers.push_back(power)
			
	# finally add the octaprobe
	m_ProbeMap.octaprobes.push_back(octaprobe)

	pass

func _create_octaprobes():
	for z in range (m_ProbeMap.dims.z):
		for y in range (m_ProbeMap.dims.y):
			for x in range (m_ProbeMap.dims.x):
				_create_octaprobe(x, y, z)
				


#func _sample_probe(var pos : Vector3, var x : int, var y: int, var z : int, var contribs):
#	var pt : Vec3i = Vec3i.new()
#	pt.x = x
#	pt.y = y
#	pt.z = z
#	pt = _clamp_to_map(pt)
#
#	var pr : Probe = _get_probe(pt)
#
#	for n in range (pr.contributions.size()):
#		var cont : Contribution = pr.contributions[n]
#
#		# get the probe light
#		var pl : ProbeLight = m_ProbeMap.lights[cont.light_id]
#		var ls : Color = Color(pl.pos.x, pl.pos.y, pl.pos.z, cont.power * pl.energy)
#
#		# is this probe in the samples?
#		var cont_id = -1
#		for c in range (contribs.size()):
#			if (contribs[c].light_id == cont.light_id):
#				cont_id = c
#				break
#
#		# not in the samples .. create it
#		if cont_id == -1:
#			cont_id = contribs.size()
#			contribs.push_back(Contribution.new())
#			contribs[cont_id].light_id = cont.light_id
#			contribs[cont_id].power = 0.0
#
#		# add the specific contribution here
#
#
#	pass

func _test_interpolate():
	var r
	r = _bilinear(0, 0, 0, 1, 0, 0)
	r = _bilinear(1, 0, 0, 1, 0, 0)
	r = _bilinear(0, 1, 0, 1, 0, 0)
	r = _bilinear(1, 1, 0, 1, 0, 0)


func _trilinear(var fx, var fy, var fz, var samples)->float:
	var c000 = samples[0]
	var c001 = samples[1]
	var c101 = samples[2]
	var c100 = samples[3]
	var c010 = samples[4]
	var c011 = samples[5]
	var c111 = samples[6]
	var c110 = samples[7]
	
	
#	prs.push_back(_get_probe_xyz(x, y, z))
#	prs.push_back(_get_probe_xyz(x, y, z+1))
#	prs.push_back(_get_probe_xyz(x+1, y, z+1))
#	prs.push_back(_get_probe_xyz(x+1, y, z))
#	prs.push_back(_get_probe_xyz(x, y+1, z))
#	prs.push_back(_get_probe_xyz(x, y+1, z+1))
#	prs.push_back(_get_probe_xyz(x+1, y+1, z+1))
#	prs.push_back(_get_probe_xyz(x+1, y+1, z))
	
#	if m_bDebugFrame:
#		print "bl"
#			print ("light pos " + str(pl.pos) + " our pos " + str(orig_pos) + " dist " + str(dist) + " power " + str(power))
	
	
	
	var e = _bilinear(fx, fy, c000, c100, c010, c110)
	var f = _bilinear(fx, fy, c001, c101, c011, c111)
	return e * (1 - fz) + (f * fz)

func _bilinear(var fx : float, var fy : float, var c00 : float, var c10 : float, var c01 : float, var c11 : float)->float:
	var a : float = c00 * (1.0 - fx) + c10 * fx
	var b : float = c01 * (1.0 - fx) + c11 * fx
	
	return a * (1.0 - fy) + (b * fy)

func sample(var pos : Vector3):
	var orig_pos = pos

	#m_bDebugFrame = (Engine.get_frames_drawn() % 100) == 0
	#_test_interpolate()
	
	# get pos in voxel space
	pos -= m_ProbeMap.ptMin
	pos /= m_ProbeMap.voxel_size

	# within?
	var pt : Vec3i = Vec3i.new()
	pt.from(pos)
	
	# fractions through the voxel
	var fx = pos.x - pt.x
	var fy = pos.y - pt.y
	var fz = pos.z - pt.z
	var inv_x = 1.0 - fx
	var inv_y = 1.0 - fy
	var inv_z = 1.0 - fz
	
	pt = _clamp_to_map(pt)

	var sr : SampleResult = SampleResult.new()

	
	# octaprobe
	var opr : Octaprobe = _get_octaprobe(pt)

	# indirect light
	sr.color_indirect.r = _trilinear(fx, fy, fz, opr.indirect_r)
	sr.color_indirect.g = _trilinear(fx, fy, fz, opr.indirect_g)
	sr.color_indirect.b = _trilinear(fx, fy, fz, opr.indirect_b)
	sr.color_indirect.a = 1.0


	var winner = -1
	var best = 0.0
	
	var closest = 99999999999.0

	var total_influence = 0.0
	var total_pos = Vector3()
	var total_power = 0.0
	var max_power = 0.0
	var total_col = Color()

	# trilinear interpolation
	for l in range (opr.lights.size()):
		var ol : Octalight = opr.lights[l]
		
		var power = _trilinear(fx, fy, fz, ol.powers)
		
#		if (power > best):
#			best = power
#			winner = l
			
		var pl : ProbeLight = m_ProbeMap.lights[ol.light_id]
		
		# special cases for types of light
		# directional
		if pl.type == 2:
			pl.pos = orig_pos - (pl.dir * m_Directional_Distance)
		
		var offset : Vector3 = pl.pos - orig_pos
		var dist = offset.length_squared() + 1.0
		
		var influence = (1.0 / dist) * power
		total_pos += pl.pos * influence
		
		total_influence += influence;
		total_power += power
		total_col += pl.color * influence
		
		if (power > max_power):
			max_power = power
		
		
#		if m_bDebugFrame:
#			print ("light pos " + str(pl.pos) + " our pos " + str(orig_pos) + " dist " + str(dist) + " power " + str(power))

		
		if (dist < closest):
			closest = dist
			winner = l
			best = power
		
		
		
	#var samples = []
	
	if (winner != -1):
		
		
		var light_id = opr.lights[winner].light_id
		var pl : ProbeLight = m_ProbeMap.lights[light_id]
		#var ls : Color = Color(pl.pos.x, pl.pos.y, pl.pos.z, best)
		#samples.push_back(ls)
		
		sr.pos = pl.pos
		sr.power = max_power

		# divide by zero? - maybe influence can never be zero
		sr.color = total_col / total_influence
		sr.pos = total_pos / total_influence
		
		
		#samples.push_back(sr)
		
	return sr
	#return samples
		
	
#	# we want to sample 8 probes, and interpolate
#	var pr : Probe = _get_probe(pt)
#
#	#var total : float = 0.0
#
#	var contribs = []
#
#	contribs = _sample_probe(pos, pt.x, pt.y, pt.z, contribs)
#	contribs = _sample_probe(pos, pt.x, pt.y, pt.z+1, contribs)
#	contribs = _sample_probe(pos, pt.x+1, pt.y, pt.z+1, contribs)
#	contribs = _sample_probe(pos, pt.x+1, pt.y, pt.z, contribs)
#
#	contribs = _sample_probe(pos, pt.x, pt.y+1, pt.z, contribs)
#	contribs = _sample_probe(pos, pt.x, pt.y+1, pt.z+1, contribs)
#	contribs = _sample_probe(pos, pt.x+1, pt.y+1, pt.z+1, contribs)
#	contribs = _sample_probe(pos, pt.x+1, pt.y+1, pt.z, contribs)
#
#	var winner : Color = Color(0, 0, 0, 0)
#
#	var samples = []
#
#	#var sz = pt.to_string()
#	for n in range (contribs.size()):
#		var cont : Contribution = contribs[n]
#		#sz += "\tlight "
#		#sz += str(cont.light_id)
#		#sz += ", "
#		#sz += str(cont.power)
#		#total += cont.power
#
#		# get the probe light
#		var pl : ProbeLight = m_ProbeMap.lights[cont.light_id]
#
#		var ls : Color = Color(pl.pos.x, pl.pos.y, pl.pos.z, cont.power)
#
#		if (ls.a > winner.a):
#			winner = ls
#
#		#ls.light_id = cont.light_id
#		#ls.power = cont.power
##		samples.push_back(ls)
#
#	#print (sz)
#	samples.push_back(winner)
#
#	return samples

func _get_probe_xyz(var x, var y, var z)->Probe:
	var pt : Vec3i = Vec3i.new()
	pt.Set(x, y, z)
	return _get_probe(pt)

func _get_octaprobe_xyz(var x, var y, var z)->Octaprobe:
	var pt : Vec3i = Vec3i.new()
	pt.Set(x, y, z)
	pt = _limit_to_map(pt)

	return _get_octaprobe(pt)
	
func _get_octaprobe(var pt : Vec3i)->Octaprobe:
	var i : int = pt.z * m_ProbeMap.XTimesY
	i += pt.y * m_ProbeMap.dims.x
	i += pt.x
	
	assert (i < m_ProbeMap.probes.size())
	return m_ProbeMap.octaprobes[i]
	

func _limit_to_map(var pt : Vec3i)->Vec3i:
	# cap to map
	if (pt.x < 0):
		pt.x = 0
	if (pt.x >= m_ProbeMap.dims.x):
		pt.x = m_ProbeMap.dims.x-1
	if (pt.y < 0):
		pt.y = 0
	if (pt.y >= m_ProbeMap.dims.y):
		pt.y = m_ProbeMap.dims.y-1
	if (pt.z < 0):
		pt.z = 0
	if (pt.z >= m_ProbeMap.dims.z):
		pt.z = m_ProbeMap.dims.z-1
		
	return pt
	

func _get_probe(var pt : Vec3i)->Probe:
	pt = _limit_to_map(pt)
	
	var i : int = pt.z * m_ProbeMap.XTimesY
	i += pt.y * m_ProbeMap.dims.x
	i += pt.x
	
	assert (i < m_ProbeMap.probes.size())
	return m_ProbeMap.probes[i]
	

func _clampi(var i : int, var mn : int, var mx : int)->int:
	if (i < mn):
		i = mn
	if (i > mx):
		i = mx
	return i

func _clamp_to_map(var pt : Vec3i)->Vec3i:
	pt.x = _clampi(pt.x, 0, m_ProbeMap.dims.x-1)
	pt.y = _clampi(pt.y, 0, m_ProbeMap.dims.y-1)
	pt.z = _clampi(pt.z, 0, m_ProbeMap.dims.z-1)
	return pt

func _read_vec3()->Vector3:
	var v = Vector3()
	v.x = m_File.get_float()
	v.y = m_File.get_float()
	v.z = m_File.get_float()
	return v


func _load_lights():
	var nLights = m_File.get_16()
	
	for n in range (nLights):
		var l : ProbeLight = ProbeLight.new()
		
		l.type = m_File.get_8()
		
		l.pos = _read_vec3()
		l.dir = _read_vec3()
		l.energy = m_File.get_float()
		l.rang = m_File.get_float()
		
		l.color.r = m_File.get_float()
		l.color.g = m_File.get_float()
		l.color.b = m_File.get_float()
		
		l.spot_angle_radians = m_File.get_float()
		
		m_ProbeMap.lights.push_back(l)
	
	pass



func _load_probeA(var x, var y, var z):
	var p : Probe = Probe.new()
	
	var nContribs = m_File.get_8()
	
	for n in range (nContribs):
		var c : Contribution = Contribution.new()
		c.light_id = m_File.get_8()
		
		p.contributions.push_back(c)


	m_ProbeMap.probes.push_back(p)
	pass

func _load_probeB(var count : int):
	var p : Probe = m_ProbeMap.probes[count]
	
	# color
	var r : float = float (m_File.get_8())
	r /= 127.0
	var g : float = float (m_File.get_8())
	g /= 127.0
	var b : float = float (m_File.get_8())
	b /= 127.0
	
	p.col_indirect = Color(r, g, b, 1.0)
	
	var nContribs = p.contributions.size()
	
	for n in range (nContribs):
		var power : float = float (m_File.get_8())
		power /= 127.0
		p.contributions[n].power = power
	
	# restore
	m_ProbeMap.probes[count] = p
	pass

func _load_probes():
	for z in range (m_ProbeMap.dims.z):
		for y in range (m_ProbeMap.dims.y):
			for x in range (m_ProbeMap.dims.x):
				_load_probeA(x, y, z)
				
	var count : int = 0
	for z in range (m_ProbeMap.dims.z):
		for y in range (m_ProbeMap.dims.y):
			for x in range (m_ProbeMap.dims.x):
				_load_probeB(count)
				count += 1
		
	pass

func load_file(var szFilename):
	m_File = File.new()
	
	var err = m_File.open(szFilename, File.READ)
	if err != OK:
		return false
	
	# load fourcc
	var fourcc_matches = 0
	
	# must be Prob (in ascii)
	var c0 = m_File.get_8()
	if (c0 == 80):
		fourcc_matches += 1
	var c1 = m_File.get_8()
	if (c1 == 114):
		fourcc_matches += 1
	var c2 = m_File.get_8()
	if (c2 == 111):
		fourcc_matches += 1
	var c3 = m_File.get_8()
	if (c3 == 98):
		fourcc_matches += 1
	
	if (fourcc_matches != 4):
		OS.alert("Error", "Not a probe file")
		return false
	
	# version
	var version = m_File.get_16()
	if (version != 100):
		OS.alert("Probe file wrong version", "Re-export with matching version")
		return false
	
	m_ProbeMap.dims.x = m_File.get_16()
	m_ProbeMap.dims.y = m_File.get_16()
	m_ProbeMap.dims.z = m_File.get_16()
	
	m_ProbeMap.XTimesY = m_ProbeMap.dims.x * m_ProbeMap.dims.y
	
	m_ProbeMap.ptMin = _read_vec3()
	m_ProbeMap.voxel_size = _read_vec3()
	
	_load_lights()
	
	_load_probes()
	
	m_File.close()
	
	_create_octaprobes()
	return true
