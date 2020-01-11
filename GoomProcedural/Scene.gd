extends Node

var m_RandList_Int = LaRandList.new()


var m_scene_Floor
var m_scene_Wall_Door_Centre
var m_scene_Wall
var m_scene_Box
var m_scene_Light

var m_scene_Portal
var m_scene_Portal_Large

var m_scene_Indicator

var m_node_Root

var m_mat_Wall : Material
var m_mat_Portal : Material
var m_mat_Floor : Material


enum eExitType {
	ET_WALL,
	ET_DOOR,
	ET_JOIN,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# generate repeatable random lists
func Rand_Init():
	for i in range (1024):
		m_RandList_Int.Add(randi())

func Rand_Seed(var s):
	# just some random prime number
	# 467 for version 0.12
	#s *= 467
	s *= 1021
	m_RandList_Int.Reset(s)
	
func Rand_Int()->int:
	return m_RandList_Int.GetValue()

func GetExitX(var exit):
	match exit:
		1:
			return 1
		3:
			return -1
	return 0

func GetExitY(var exit):
	match exit:
		0:
			return -1
		2:
			return 1
	return 0

func GetOppositeExit(var exit):
	match exit:
		0:
			return 2
		1:
			return 3
		2:
			return 0
		3:
			return 1
	assert (0)
	

func setup():
	
#	var color = Color(0.1, 0.8, 0.1)
#	m_mat_Wall = SpatialMaterial.new()
#	m_mat_Wall.albedo_color = color
#	m_mat_Wall.params_cull_mode = SpatialMaterial.CULL_DISABLED

	var color2 = Color(0.8, 0.1, 0.1)
	m_mat_Portal = SpatialMaterial.new()
	m_mat_Portal.albedo_color = color2
	#m_mat_Portal.params_cull_mode = SpatialMaterial.CULL_DISABLED

	#var color3 = Color(0.8, 0.8, 0.8)
	#m_mat_Floor = SpatialMaterial.new()
	#m_mat_Floor.albedo_color = color3
	#m_mat_Floor.params_cull_mode = SpatialMaterial.CULL_DISABLED
	
	
	m_mat_Floor = load("res://Modular/Materials/Mat_Floor.tres")
	m_mat_Wall = load("res://Modular/Materials/Mat_Wall.tres")
	

	Rand_Init()
	#m_scene_Floor = load("res://Modular/Floor.tscn")
	#m_scene_Wall = load("res://Modular/Wall.tscn")
	#m_scene_Wall_Door_Centre = load("res://Modular/Wall_Door_Centre.tscn")
	m_scene_Box = load("res://Modular/Box.tscn")
	m_scene_Light = load("res://Modular/Light.tscn")
	
	#m_scene_Portal = load("res://Modular/portal.tscn")
	#m_scene_Portal_Large = load("res://Modular/portal_large.tscn")
	
	#m_scene_Indicator = load("res://Modular/Indicator.tscn")
	
	m_node_Root = get_node("/root/Root")
	#m_node_Spotlight = m_node_Root.find_node("Spotlight_Test", true, false)
	pass

