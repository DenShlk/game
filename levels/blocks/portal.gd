extends Interactable

@export var destination_level: PackedScene

func _ready():
	super()
	assert(destination_level != null, "no destination set!")
	

func interact(node: CombatCharacter):
	if multiplayer.is_server():
		if node is PlayerCharacter:
			var info: PlayerInfo = node.player_info
			info.destroy_character(node)
			var level: BaseLevel = LevelLoader.add_level_unless_exists(destination_level)
			LevelLoader.MovePlayer(info.create_character(), level)
	else:
		_remote_interact.rpc_id(1, node.get_path())
		
		
@rpc("any_peer", "call_remote", "reliable", 2)		
func _remote_interact(node_path: NodePath):
	assert(multiplayer.is_server(), "call this only on server")
	print('teleporting node by path: %s' % node_path)
	var node := get_node(node_path) as CombatCharacter
	interact(node)
	
