extends Node2D

@export var start_level: PackedScene

var peer: MultiplayerPeer
var ip: String
var port: int
var level_seed: int
var player_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()
	GameManager.info_arrived_to_server.connect(info_arrived_to_server)

# this get called on the server and clients
func peer_connected(id):
	print("Player Connected " + str(id))
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	GameManager.remove_player(id)
	
# called only from clients
func connected_to_server():
	print("connected To Sever!")
	send_player_information.rpc_id(1,
			multiplayer.get_unique_id(),
			player_name,
			100,
			100,
			0
			)
	
	
# called only from clients
func connection_failed():
	print("Couldnt Connect")


func info_arrived_to_server():
	if !multiplayer.is_server():
		StartGame(multiplayer.get_unique_id())


var _player_info_node: PackedScene = load("res://multiplayer/player_info.tscn")


@rpc("any_peer", "call_local", "reliable", 1)
func send_player_information(id, nick, finished_with_health, max_health, money):
	if multiplayer.is_server():
		var player := _player_info_node.instantiate() as PlayerInfo
		player.name = str(id)
		player.id = id
		player.finishedWithHealth = finished_with_health
		player.maxHealth = max_health
		player.nick = nick
		player.money = money
		GameManager.add_player(player)
	else:
		assert(false, "call this only on server")

@rpc("any_peer", "call_remote", "reliable", 1)
func StartGame(id: int):
	if multiplayer.is_server():
		var level: BaseLevel = LevelLoader.FindLevel(start_level)
		if level == null:
			level = start_level.instantiate()
			LevelLoader.AddLevel(level)
		var player: PlayerInfo = GameManager.get_player_info_by_id(id)
		LevelLoader.MovePlayer(player.create_character(), level)
	else:
		StartGame.rpc_id(1, id)
	self.hide()
	$CanvasLayer.hide()
	
func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: %s" % error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting For Players!")
	
	
func collect_inputs():
	ip = $CanvasLayer/ui/CenterContainer/VBoxContainer/GridContainer/ip.text
	port = $CanvasLayer/ui/CenterContainer/VBoxContainer/GridContainer/port.value
	level_seed = $CanvasLayer/ui/CenterContainer/VBoxContainer/GridContainer/seed.value
	player_name = $CanvasLayer/ui/CenterContainer/VBoxContainer/GridContainer/name.text
		
func _on_host_button_down():
	collect_inputs()
	hostGame()
	send_player_information(
			multiplayer.get_unique_id(),
			player_name,
			100,
			100,
			0
			)
	StartGame(multiplayer.get_unique_id())


func _on_join_button_down():
	collect_inputs()
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_game_button_down():
	print('why do we need that button anyway?')
	return
	collect_inputs()
	if peer == null:
		_on_host_button_down()
	GameManager.set_seed(level_seed)
	StartGame.rpc()
