class_name ServerInteractable
extends Interactable

func interact(node: CombatCharacter):
	if multiplayer.is_server():
		super(node)
	else:
		_remote_interact.rpc_id(1, node.get_path())

func _interact(node: CombatCharacter):
	super(node)
		
		
@rpc("any_peer", "call_remote", "reliable", 2)		
func _remote_interact(node_path: NodePath):
	assert(multiplayer.is_server(), "call this only on server")
	
	var node := get_node(node_path) as CombatCharacter
	interact(node)


# overriding this (rpc) doesn't do good
@rpc("any_peer", "call_remote", "reliable", 2)
func set_enabled(enabled: bool, call_others: bool = false):
	if call_others:
		set_enabled.rpc(enabled)
	super(enabled)
	_set_enabled_local(enabled)

# will be called on each peer, use to make changes you would in set_enabled
func _set_enabled_local(enabled: bool):
	pass
