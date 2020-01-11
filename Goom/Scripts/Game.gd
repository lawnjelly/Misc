extends Node

var m_MouseSensitivity = 0.003  # radians/pixel
var m_ptVel = Vector3(0, 0, 0)

var m_Player_GID : int = -1

func Level_Start():
	m_Player_GID = Graph_Objects.create_obj()


func TickUpdate(delta):
	move_firstperson(delta)
	Graph_Objects.iterate_all()
	pass
	
func FrameUpdate(delta):
	pass

# mouse look
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Scene.m_node_Controller.rotate_y(-event.relative.x * m_MouseSensitivity)
		Scene.m_node_Cam_First.rotate_x(-event.relative.y * m_MouseSensitivity)
		Scene.m_node_Cam_First.rotation.x = clamp(Scene.m_node_Cam_First.rotation.x, -1.2, 1.2)
		
# 1st person shooter type control
func move_firstperson(delta):
	
	var angle = 0.0
	var move = Vector2(0, 0)
	var height = 0
	
	if Input.is_action_pressed("ui_left"):
		move.x -= 1
		#angle += delta
	if Input.is_action_pressed("ui_right"):
		move.x += 1
		#angle -= delta
	if Input.is_action_pressed("ui_up"):
		move.y += 1
	if Input.is_action_pressed("ui_down"):
		move.y -= 1
		
	if Input.is_action_pressed("ui_page_down"):
		height -= 1
	if Input.is_action_pressed("ui_page_up"):
		height += 1
	
		
	# get forward vector
	angle = -Scene.m_node_Controller.rotation.y + (PI / 2)
	
	var forward = -Vector2(cos(angle), sin(angle))
	var right = Vector2(-forward.y, forward.x)
	
	move *= 0.3
	height *= 0.3

	var ptPush = Vector3()

	ptPush.x += forward.x * move.y
	ptPush.z += forward.y * move.y
	
	ptPush.x += right.x * move.x
	ptPush.z += right.y * move.x

	ptPush.y += height

	Graph_Objects.push(m_Player_GID, ptPush * delta)

	var tr = Scene.m_node_Controller.translation
	#tr += m_ptVel * delta
	tr = Graph_Objects.get_pos(m_Player_GID)
	
	#print ("pos " + str(tr))
	Scene.m_node_Controller.translation = tr

	# friction
	#m_ptVel *= 0.9
