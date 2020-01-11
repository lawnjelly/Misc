extends Spatial

##############################
# Change this from false to true to create the UVs, the proxy, and the final UV mapped level
#var m_bPrepare = false
##############################

#var cam_third
#var cam_first
#var m_Controller
#var m_RoomManager : LRoomManager
#var which_cam = 0
#const MAP_SIZE_X = 4
#const MAP_SIZE_Y = 4
#var lportal_active = true
#
#var m_bDebugPlanes = false
#var m_bDebugBounds = false
#var m_bMouseCaptured = false
#
#var m_bFirstRun = true
##var m_node_StartRoom
#
#var m_ptVel = Vector3(0, 0, 0)
#var m_MouseSensitivity = 0.003  # radians/pixel
#
## timing
#var m_iDisplayTimeout = 0
#var m_iTick = 0

	

# Called when the node enters the scene tree for the first time.
#func _ready():
#	m_RoomManager = $LRoomManager
#
#	#m_node_StartRoom = $Level.get_node("room_8")
#
#	m_Controller = $Controller
#	cam_first = $Controller/Camera_First
#	#cam_third = $Controller/Camera2/Camera
#	cam_third = $Controller/Camera_Third
#
#	#$RoomGroup.light_register($DirectionalLight)
#
#	#$RoomGroup.rooms_set_logging(0)
#	#$RoomGroup.rooms_set_debug_lights(true)
#	if m_bPrepare:
#		#var Merged = m_RoomManager.lightmap_internal("res://Lightmaps/Lightmap_Proxy.tscn", "res://Levels/Map_Final.tscn")
#		m_RoomManager.lightmap_external_export("../export.dae")
#		#m_RoomManager.lightmap_set_unmerge_params(0.001, 0.99)
#		#m_RoomManager.lightmap_external_unmerge($Proxy, "External/Final.tscn")
#	else:
#		LoadLevelAndRun()
#
#func UnloadLevel():
#	# unregister all the dobs
#	m_RoomManager.dob_unregister(cam_first)
#
##	for i in range ($Monsters.get_child_count()):
##		var mon = $Monsters.get_child(i)
##		m_RoomManager.dob_unregister(mon)
#
#	# test release
#	m_RoomManager.rooms_release()
#
#	# reload level
#	var level_old = $Level
#	level_old.set_name("level_delete")
#	level_old.queue_free()
#
#func LoadLevelAndRun():
#
#	#var scene_level = load("res://Levels/Map_Final.tscn")
#	#var level = scene_level.instance()
#	#add_child(level)
#
#	Graph_Load.import("Levels/myrooms.lev")
#
#	m_RoomManager.rooms_set_portal_plane_convention(true)
#	#m_RoomManager.rooms_set_hide_method_detach(false)
#	m_RoomManager.rooms_convert(true, true)
#	#m_RoomManager.rooms_set_debug_planes(true)
#	#m_RoomManager.rooms_set_debug_bounds(true)
#
#	m_RoomManager.rooms_set_camera(cam_third)
#	m_RoomManager.rooms_set_camera(cam_first)
#
#	m_RoomManager.dob_register(cam_first, 0)	
#	#m_RoomManager.dob_register_hint(cam_first, 0, m_node_StartRoom)	
#
#	#m_RoomManager.light_register($DirectionalLight, "default")
#
#	m_RoomManager.rooms_set_debug_frame_string(true)
#	#if (m_bFirstRun):
#	#	setup_monsters()
#
#	#register_monsters()
#
#	m_bFirstRun = false
#
#
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_just_pressed("ui_cancel"):
#		get_tree().quit()
#		return
#
#	# don't do much on a frame if we are only preparing .. no DOB updates etc
#	if m_bPrepare:
#		return
#
#	if Input.is_action_just_pressed("ui_accept"):
#		App.DisplayMessage("Reloading Level")
#		UnloadLevel()
#		LoadLevelAndRun()
#		return
#
#	if Input.is_action_just_pressed("ui_select"):
#		if which_cam == 0:
#			App.DisplayMessage("1st Person Camera")
#			which_cam = 1
#			cam_first.make_current()
#		else:
#			App.DisplayMessage("3rd Person Camera")
#			cam_third.make_current()
#			which_cam = 0
#			m_RoomManager.rooms_set_camera(cam_first)
#			# force debug output
#			m_RoomManager.rooms_log_frame()
#
#	if Input.is_action_just_pressed("ui_focus_next"):
#		if lportal_active == true:
#			lportal_active = false
#			App.DisplayMessage("LPortal OFF")
#		else:
#			lportal_active = true
#			App.DisplayMessage("LPortal ON")
#
#		m_RoomManager.rooms_set_active(lportal_active)
#
#
#	if Input.is_action_just_pressed("ui_home"):
#		#m_bDebugBounds = (m_bDebugBounds == false)
#		#$RoomGroup.rooms_set_debug_bounds(m_bDebugBounds)
#		if m_bMouseCaptured:
#			App.DisplayMessage("Mouse Released")
#			m_bMouseCaptured = false
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
#		else:
#			App.DisplayMessage("Mouse Captured")
#			m_bMouseCaptured = true
#			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
#
#			# test visible room
#			var vis_rooms = m_RoomManager.rooms_get_visible_rooms()
#			for r in range (vis_rooms.size()):
#				print("room " + str(vis_rooms[r]))
#
#	if Input.is_action_just_pressed("ui_end"):
#		m_bDebugPlanes = (m_bDebugPlanes == false)
#		m_RoomManager.rooms_set_debug_planes(m_bDebugPlanes)
#
#
#	move_firstperson(delta)
#
#	var room_id = m_RoomManager.dob_update(cam_first)
#
#	if room_id != -1:
#		var ptRoomCentre = m_RoomManager.rooms_get_room_centre(room_id)
#		$Cube.translation = ptRoomCentre
#
#	#DisplayMessage(m_RoomManager.rooms_get_debug_frame_string())
#
##	for i in range ($Monsters.get_child_count()):
##		var mon = $Monsters.get_child(i)
##		m_RoomManager.dob_update(mon)
#	pass
#
#
## mouse look
#func _unhandled_input(event):
#	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		m_Controller.rotate_y(-event.relative.x * m_MouseSensitivity)
#		cam_first.rotate_x(-event.relative.y * m_MouseSensitivity)
#		cam_first.rotation.x = clamp(cam_first.rotation.x, -1.2, 1.2)
#
## 1st person shooter type control
#func move_firstperson(delta):
#
#	var angle = 0.0
#	var move = Vector2(0, 0)
#	var height = 0
#
#	if Input.is_action_pressed("ui_left"):
#		move.x -= 1
#		#angle += delta
#	if Input.is_action_pressed("ui_right"):
#		move.x += 1
#		#angle -= delta
#	if Input.is_action_pressed("ui_up"):
#		move.y += 1
#	if Input.is_action_pressed("ui_down"):
#		move.y -= 1
#
#	if Input.is_action_pressed("ui_page_down"):
#		height -= 1
#	if Input.is_action_pressed("ui_page_up"):
#		height += 1
#
#
#	# get forward vector
#	angle = -m_Controller.rotation.y + (PI / 2)
#
#	var forward = -Vector2(cos(angle), sin(angle))
#	var right = Vector2(-forward.y, forward.x)
#
#	move *= 0.3
#	height *= 0.3
#
#	m_ptVel.x += forward.x * move.y
#	m_ptVel.z += forward.y * move.y
#
#	m_ptVel.x += right.x * move.x
#	m_ptVel.z += right.y * move.x
#
#	m_ptVel.y += height
#
#	var tr = m_Controller.translation
#	tr += m_ptVel * delta
#	m_Controller.translation = tr
#
#	# friction
#	m_ptVel *= 0.9


#func setup_monsters():
#	return
#
#	var mon = load("res://Monster/Monster.tscn")
#	for i in range (4):
#		var m = mon.instance()
#		$Monsters.add_child(m)
#		m.setup(MAP_SIZE_X * 4, MAP_SIZE_Y * 4)
#	pass
#
#func register_monsters():
#	return
#	for i in range ($Monsters.get_child_count()):
#		var mon = $Monsters.get_child(i)
#		m_RoomManager.dob_register(mon, 0.5)


#func _physics_process(delta):
#	m_iTick += 1
#	UpdateMessage()
#
#
#func DisplayMessage(var msg):
#	$UI/Info.text = msg
#	m_iDisplayTimeout = m_iTick + 60
#
#func UpdateMessage():
#	if m_iDisplayTimeout != 0:
#		if m_iTick >= m_iDisplayTimeout:
#			m_iDisplayTimeout = 0
#			$UI/Info.text = ""
