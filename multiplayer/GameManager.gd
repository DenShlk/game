extends Node

signal info_arrived_to_server

var _seed: int = -2

func get_seed() -> int:
	print('returned seed: ', _seed)
	return _seed

func set_seed(s):
	if s == -1:
		s = randi()
	_set_seed.rpc(s)

@rpc("any_peer", "call_local", "reliable", 2)
func _set_seed(s):
	print('set seed to', s)
	_seed = s
	
var id_counter = 1000

func give_id() -> int:
	assert(multiplayer.is_server(), "only server is allowed to give ids")
	id_counter += 1
	return id_counter

# not synced, maps id of node to node itself
@export
var id2node: Dictionary = {}

func add_player(node: PlayerInfo):
	$players.add_child(node, true)
	on_player_state_arrived(node)
	
func remove_player(id: int):
	if player_id2info.has(id):
		$players.remove_child(player_id2info[id])
		
func get_player_info_by_id(id: int) -> PlayerInfo:
	return player_id2info[id]
	
func get_players_count() -> int:
	return player_id2info.size()

# stores player info links for quick lookup. note that spawning is not instant with connection.

var player_id2info: Dictionary = {}

func on_player_state_arrived(node: PlayerInfo):
	player_id2info[node.id] = node
	if node.id == multiplayer.get_unique_id():
		info_arrived_to_server.emit()
		

func _on_players_child_exiting_tree(node):
	if node is PlayerInfo:
		player_id2info.erase(node.id)
	else:
		assert(false, "you are not supposed to be here")
