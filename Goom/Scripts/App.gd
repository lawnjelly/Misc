extends Node

##############################
# Change this from false to true to create the UVs, the proxy, and the final UV mapped level
var m_bPrepare = false
##############################


var m_bDebugPlanes = false
var m_bDebugBounds = false
var m_bMouseCaptured = false

var m_WhichCam = 0
var m_bLPortalActive = true
var m_bFirstRun = true


# timing
var m_iDisplayTimeout = 0
var m_iTick = 0

var m_bStarted = false

func _ready():
	App_Start()
	pass # Replace with function body.

func App_Start():
	Scene.App_Start()
	#$RoomGroup.light_register($DirectionalLight)
	
	#$RoomGroup.rooms_set_logging(0)
	#$RoomGroup.rooms_set_debug_lights(true)
	if m_bPrepare:
		#var Merged = m_RoomManager.lightmap_internal("res://Lightmaps/Lightmap_Proxy.tscn", "res://Levels/Map_Final.tscn")
		Scene.m_RoomManager.lightmap_external_export("../export.dae")
		#m_RoomManager.lightmap_set_unmerge_params(0.001, 0.99)
		#m_RoomManager.lightmap_external_unmerge($Proxy, "External/Final.tscn")
	else:
		LoadLevelAndRun()
		
	#m_bStarted = true
	

func _process(delta):
	Game.FrameUpdate(delta)
	#if not m_bStarted:
	#	return
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		return

	# don't do much on a frame if we are only preparing .. no DOB updates etc
	if m_bPrepare:
		return

	if Input.is_action_just_pressed("ui_accept"):
		App.DisplayMessage("Reloading Level")
		UnloadLevel()
		LoadLevelAndRun()
		return
	
	if Input.is_action_just_pressed("ui_select"):
		if m_WhichCam == 0:
			DisplayMessage("1st Person Camera")
			m_WhichCam = 1
			Scene.m_node_Cam_First.make_current()
		else:
			DisplayMessage("3rd Person Camera")
			Scene.m_node_Cam_Third.make_current()
			m_WhichCam = 0
			Scene.m_RoomManager.rooms_set_camera(Scene.m_node_Cam_First)
			# force debug output
			Scene.m_RoomManager.rooms_log_frame()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		if m_bLPortalActive == true:
			m_bLPortalActive = false
			DisplayMessage("LPortal OFF")
		else:
			m_bLPortalActive = true
			DisplayMessage("LPortal ON")
			
		Scene.m_RoomManager.rooms_set_active(m_bLPortalActive)
	
	
	if Input.is_action_just_pressed("ui_home"):
		#m_bDebugBounds = (m_bDebugBounds == false)
		#$RoomGroup.rooms_set_debug_bounds(m_bDebugBounds)
		if m_bMouseCaptured:
			DisplayMessage("Mouse Released")
			m_bMouseCaptured = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
		else:
			DisplayMessage("Mouse Captured")
			m_bMouseCaptured = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
			
			# test visible room
			var vis_rooms = Scene.m_RoomManager.rooms_get_visible_rooms()
			for r in range (vis_rooms.size()):
				print("room " + str(vis_rooms[r]))
			
	if Input.is_action_just_pressed("ui_end"):
		m_bDebugPlanes = (m_bDebugPlanes == false)
		Scene.m_RoomManager.rooms_set_debug_planes(m_bDebugPlanes)
			
	
	#Game.move_firstperson(delta)
	
	var room_id = Scene.m_RoomManager.dob_update(Scene.m_node_Cam_First)
	
	if room_id != -1:
		var ptRoomCentre = Scene.m_RoomManager.rooms_get_room_centre(room_id)
		Scene.m_node_Root.get_node("Cube").translation = ptRoomCentre
	
	#DisplayMessage(m_RoomManager.rooms_get_debug_frame_string())
		
#	for i in range ($Monsters.get_child_count()):
#		var mon = $Monsters.get_child(i)
#		m_RoomManager.dob_update(mon)
	pass


func _physics_process(delta):
	Game.TickUpdate(delta)
	m_iTick += 1
	UpdateMessage()


func UnloadLevel():
	# unregister all the dobs
	Scene.m_RoomManager.dob_unregister(Scene.m_node_Cam_First)
	
#	for i in range ($Monsters.get_child_count()):
#		var mon = $Monsters.get_child(i)
#		m_RoomManager.dob_unregister(mon)

	# test release
	Scene.m_RoomManager.rooms_release()
	
	# reload level
	var level_old = Scene.m_node_Root.get_node("Level")
	level_old.set_name("level_delete")
	level_old.queue_free()

func LoadLevelAndRun():
	
	#var scene_level = load("res://Levels/Map_Final.tscn")
	#var level = scene_level.instance()
	#add_child(level)
	
	Graph_Load.import("Levels/myrooms.lev")
	Game.Level_Start()
	
	Scene.m_RoomManager.rooms_set_portal_plane_convention(true)
	#m_RoomManager.rooms_set_hide_method_detach(false)
	Scene.m_RoomManager.rooms_convert(true, true)
	#m_RoomManager.rooms_set_debug_planes(true)
	#m_RoomManager.rooms_set_debug_bounds(true)
	
	Scene.m_RoomManager.rooms_set_camera(Scene.m_node_Cam_Third)
	Scene.m_RoomManager.rooms_set_camera(Scene.m_node_Cam_First)

	Scene.m_RoomManager.dob_register(Scene.m_node_Cam_First, 0)	
	#m_RoomManager.dob_register_hint(cam_first, 0, m_node_StartRoom)	

	#m_RoomManager.light_register($DirectionalLight, "default")
	
	Scene.m_RoomManager.rooms_set_debug_frame_string(true)
	#if (m_bFirstRun):
	#	setup_monsters()
		
	#register_monsters()
	
	m_bFirstRun = false
	
	


func DisplayMessage(var msg):
	Scene.m_node_Info.text = msg
	m_iDisplayTimeout = m_iTick + 60
	
func UpdateMessage():
	if m_iDisplayTimeout != 0:
		if m_iTick >= m_iDisplayTimeout:
			m_iDisplayTimeout = 0
			Scene.m_node_Info.text = ""
