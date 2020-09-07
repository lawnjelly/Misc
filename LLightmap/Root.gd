extends Spatial

var m_iTick = 0
var m_iDisplayTimeout = 0

var m_Probes : LightProbes = LightProbes.new()

var m_Mesh : MeshInstance
var m_Sampler : Spatial
var m_Camera: Camera
var m_CameraHolder: Spatial

var m_AnimationTreePlayer

var m_ColIndirect : Color = Color()

func deferred_setup():
	setup_lighting_recursive($Level)


# Called when the node enters the scene tree for the first time.
func _ready():
	m_Probes.load_file("res://Lightmaps/LightMap.probe")
	m_Sampler = $Sampler
	m_Mesh = $Sampler/FrogRoot/Armature/Skeleton/Skin
	m_Camera = $Sampler/CameraHolder/Camera
	m_CameraHolder = $Sampler/CameraHolder
	m_AnimationTreePlayer = $Sampler/FrogRoot/AnimationTreePlayer
	
	#call_deferred("deferred_setup")
	pass
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		return


	if Input.is_action_just_pressed("ui_accept"):
		DisplayMessage("Reloading Level")
		return
	
	#if Input.is_action_just_pressed("ui_select"):
	#if Input.is_action_just_pressed("ui_focus_next"):
	#if Input.is_action_just_pressed("ui_home"):
	#if Input.is_action_just_pressed("ui_end"):
	
	m_Mesh.rotate_y(0.01)
	
	#m_CameraHolder.rotate_y(0.01)
	move_firstperson(delta)
	
	update_lighting(delta)
	pass
	
	
# mouse look
#func _unhandled_input(event):
#	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		m_Controller.rotate_y(-event.relative.x * m_MouseSensitivity)
#		cam_first.node.rotate_x(-event.relative.y * m_MouseSensitivity)
#		cam_first.node.rotation.x = clamp(cam_first.node.rotation.x, -1.2, 1.2)
		
# 1st person shooter type control
func move_firstperson(delta):
	
	var angle = 0.0
	var move = Vector2(0, 0)
	
	if Input.is_action_pressed("ui_left"):
		move.x -= 1
		#angle += delta
		m_AnimationTreePlayer.oneshot_node_start("Jump")
	if Input.is_action_pressed("ui_right"):
		move.x += 1
		#angle -= delta
		m_AnimationTreePlayer.oneshot_node_start("Die")
	if Input.is_action_pressed("ui_up"):
		move.y += 1
		m_AnimationTreePlayer.oneshot_node_start("Drown")
	if Input.is_action_pressed("ui_down"):
		move.y -= 1
		m_AnimationTreePlayer.oneshot_node_start("Dance")

		
	var pos = m_Sampler.translation
	
	move *= delta * 1.0
	pos.x += move.x
	pos.z -= move.y
	m_Sampler.translation = pos



func _physics_process(delta):
	m_iTick += 1
	UpdateMessage()
	

func setup_lighting_recursive(var node : Node):

	if node is MeshInstance:
		var mi : MeshInstance = node
		
		var mat : Material = mi.get_surface_material(0)

		if mat is ShaderMaterial:
			var col = Color(0, 0, 0, 0)
			var pos : Vector3 = Vector3()

			var bb : AABB = mi.get_transformed_aabb()
			var sample_pos = bb.position + bb.size  + Vector3(0, 0.3, 0)
			var sample = m_Probes.sample(sample_pos)

			pos = sample.pos
			#power = sample.power
			col = sample.color

			if pos != Vector3(0, 0, 0):
				mat.set_shader_param("light_pos", pos)
				mat.set_shader_param("light_color", col)

	
	
	for c in range (node.get_child_count()):
		setup_lighting_recursive(node.get_child(c))
	
	
func update_lighting(delta):
	var sample_pos = m_Sampler.translation + Vector3(0, 0.5, 0)
	var sample = m_Probes.sample(sample_pos)
	
	var mat : Material = m_Mesh.get_surface_material(0)
	
	#var scol : Color = Color(-100, -100, -100, 1)
	var power = 0.0
	var col = Color(0, 0, 0, 0)
	
#	var res : SampleResult = SampleResult.new()
#	res.pos = 

	var pos : Vector3 = Vector3()
	
	pos = sample.pos
	power = sample.power
	col = sample.color
		#scol = samples[0]
		#power = scol.a

	# convert light world space to model space
#	var tr : Transform = m_Mesh.global_transform
#	tr = tr.affine_inverse()
	
	
#	pos.x = scol.r
#	pos.y = scol.g
#	pos.z = scol.b
	
#	if ((Engine.get_frames_drawn() % 100) == 0):
#		print ("light pos " + str(pos) + " our pos " + str(sample_pos))
	
	
	#pos = tr.xform(pos)
	#pos = pos.normalized()
#	pos *= 0.1

#	scol.r = pos.x
#	scol.g = pos.y
#	scol.b = pos.z

	col *= power

	# balance indirect light here
	sample.color_indirect *= 0.6

	# lerp towards this color
	var fraction : float = delta * 3.0
	if (fraction > 1.0):
		fraction = 1.0
		
	m_ColIndirect = lerp(m_ColIndirect, sample.color_indirect, fraction)

	# test blank the light color
	#col = Color(0, 0, 0, 0)
	
	var cam_pos = m_Camera.global_transform.origin
	
	mat.set_shader_param("light_pos", pos)
	mat.set_shader_param("light_color", col)
	mat.set_shader_param("light_indirect", m_ColIndirect)
	#mat.set_shader_param("view_posu", cam_pos)


func DisplayMessage(var msg):
	$UI/Info.text = msg
	m_iDisplayTimeout = m_iTick + 60
	
func UpdateMessage():
	if m_iDisplayTimeout != 0:
		if m_iTick >= m_iDisplayTimeout:
			m_iDisplayTimeout = 0
			$UI/Info.text = ""
