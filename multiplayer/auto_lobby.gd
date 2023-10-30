extends Node2D

@onready var lobby = $lobby
@onready var name_label: LineEdit = $lobby/CanvasLayer/ui/CenterContainer/VBoxContainer/GridContainer/name

func _ready():
	var _instance_socket = TCPServer.new()
	if _instance_socket.listen(5001) == OK:
		# can connect => first instance => alpha => best of the best => server
		name_label.text = "server"
		lobby._on_host_button_down()
	else:
		# cannot connect => join
		name_label.text = "enjoiner"
		lobby._on_join_button_down()
	await get_tree().create_timer(10).timeout
	_instance_socket.stop()
