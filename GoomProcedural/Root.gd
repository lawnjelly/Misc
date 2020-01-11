extends Spatial


func setup():
	Scene.setup()
	#$PRooms.setup()
	Generator.Create($RoomList)
	$LRoomManager.rooms_save_scene($RoomList, "myrooms.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()
	#TestSIMD()
	#TestVec2()
	#TestVec4i()
	#TestDot()
	#TestVector()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Graph.Iterate($ImmediateGeometry)
	pass

#func TestVector():
#	var vt = VectorTest.new()
#	var numTests = 1000000 / 1
#
#	var totals = []
#	totals.push_back(0)
#	totals.push_back(0)
#	totals.push_back(0)
#	totals.push_back(0)
#	totals.push_back(0)
#	totals.push_back(0)
#
#	var numMethods = 6
#
#	for i in range (12):	
#		for t in range (numMethods):
#			var taken = vt.Test(numTests, t)
#			if i > 0:
#				totals[t] += taken
##
#	print("\nGrand Totals : ")
#	for t in range (numMethods):
#		print ("method " + str(t) + " : " + str(totals[t]))

	# old
	# safe value
	# safe test
	# random shaper
	# compile time select
	# unlikely


const simd_size = 500000

#func TestVec4i():
#	var v4 = Vec4_i32.new()
#	var varr = FastArray_4i32.new()
#	varr.reserve(16)
#
#	v4.set_xyzw(1, 2, 3, 4)
#
#	for t in range (8):
#		print ("start")
#		for i in range (1):
#			varr.write(0, v4)
#			var res = varr.read(0)
#
#			#print("result " + str(res.x()))
#	pass
#
#func TestVec2():
#
#	var farr = FastArray_2f32.new()
#	farr.reserve(simd_size)
#
#	for i in range (simd_size):
#		farr.write(i, Vector2(1, 1))
#
#	farr.value_add(Vector2(2, 3), 0, simd_size)
#	farr.length_squared(1, 2)
#	farr.normalize(0, simd_size)
#
#	print ("vec2 SIMD")
#	for i in range (16):
#		print (str(farr.read(i)) + " : " + str(farr.read_result(i)))
#
#func TestDot():
#	var test_size = 16
#	var fast_arr = FastArray_4f32.new()
#	fast_arr.reserve(test_size)
#	var fast_arr2 = FastArray_4f32.new()
#	fast_arr2.reserve(test_size)
#
#	var rg = 100.0
#
#	for i in range (test_size):
#		var pt = Vector3(rand_range(-rg, rg), rand_range(-rg, rg), rand_range(-rg, rg))
#		fast_arr.write(i, Quat(pt.x, pt.y, pt.z, 0))
#		var pt2 = Vector3(rand_range(-rg, rg), rand_range(-rg, rg), rand_range(-rg, rg))
#		fast_arr2.write(i, Quat(pt2.x, pt2.y, pt2.z, 0))
#
#		print (str(i) + "\tdot : " + str(pt.dot(pt2)))
#
#	fast_arr.vec3_dot(fast_arr2, 0, test_size)
#
#	for i in range (test_size):
#		var q = fast_arr.read(i)
#		print (str(i) + "\tfast dot : " + str(q.w))
#
#	pass
#
#
#func TestSIMD():
#	var fast_arr = FastArray_4f32.new()
#	fast_arr.reserve(simd_size)
#	var fast_arr2 = FastArray_4f32.new()
#	fast_arr2.reserve(simd_size)
#
#	print (fast_arr.get_cpu_name())
#	print (fast_arr.get_cpu_caps(" "))
#
#
#	var norm_arr = PoolVector3Array([0])
#	norm_arr.resize(simd_size)
#
#	var tr = Transform()
#
#	for i in range (simd_size):
#		fast_arr.write(i, Quat(1, 1, 1, 1))
#		fast_arr2.write(i, Quat(1, 1, 1, 1))
#
#		norm_arr.set(i, Vector3(1, 1, 1))
#
#
#	var before = OS.get_ticks_msec()
#	#fast_arr.value_add(Quat(1, 1, 1, 1), 0, size)
#	#fast_arr.sqrt(0, simd_size)
#	fast_arr.vec3_dot(fast_arr2, 0, simd_size)
#	#fast_arr.vec3_xform_inv(tr, 0, size)
#	var after = OS.get_ticks_msec()
#
#	var q_add = Quat(1, 1, 1, 1)
#	var v_add = Vector3(1, 1, 1)
#
#	var before2 = OS.get_ticks_msec()
#	fast_arr.sqrt(0, simd_size)
#	var after2 = OS.get_ticks_msec()
#
#
#	var temp = Vector3()
#	var before3 = OS.get_ticks_msec()
#	for i in range (simd_size):
#	#	temp = norm_arr[i]
#	#	temp += v_add
#
#		#norm_arr.set(i, norm_arr[i] + q_add)
#		#norm_arr[i] = tr.xform_inv(norm_arr[i])
#
#		#temp.x = sqrt(norm_arr[i].x)
#		#temp.y = sqrt(norm_arr[i].y)
#		#temp.z = sqrt(norm_arr[i].z)
#		#temp.z = sqrt(norm_arr[i].z)
#		var dot = norm_arr[i].dot(norm_arr[i])
#
#		norm_arr.set(i, temp)
#
#	var after3 = OS.get_ticks_msec()
#
#
#	var q = fast_arr.read(0)
#	print("result : " + str(q))
#
#	print("timing 1 " + str(after - before))
#	print("timing 2 " + str(after2 - before2))
#	print("timing 3 " + str(after3 - before3))
#
#	pass
#
#func PassSIMD(var arr):
#	arr.value_add(Quat(1, 1, 1, 1), 0, simd_size)
#
