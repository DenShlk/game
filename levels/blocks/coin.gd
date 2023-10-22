extends ServerInteractable

@export var amount: int = 25
var taken := false

func interact(node: CombatCharacter):
	if node is PlayerCharacter:
		super(node)
		
func _interact(node: CombatCharacter):
	if taken:
		return
		
	if node is PlayerCharacter:
		var info: PlayerInfo = node.player_info
		info.money += amount
		taken = true
		queue_free()
	else:
		assert(false, "not player nodes should be here")
		
