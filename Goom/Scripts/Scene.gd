extends Node

var m_node_Root

var m_node_Controller
var m_node_Cam_First
var m_node_Cam_Third

var m_node_Info

var m_RoomManager : LRoomManager

func App_Start():
	m_node_Root = get_node("/root/Root")
	m_node_Controller = m_node_Root.get_node("Controller")
	m_node_Cam_First = m_node_Controller.get_node("Camera_First")
	m_node_Cam_Third = m_node_Controller.get_node("Camera_Third")
	m_node_Info = m_node_Root.get_node("UI/Info")

	m_RoomManager = m_node_Root.get_node("LRoomManager")
