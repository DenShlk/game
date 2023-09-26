extends Node
class_name PlayerInfo

@export var id: int
@export var nick: String
@export var finishedWithHealth: int
@export var money: int
@export var maxHealth: int
@export var weaponPath: NodePath

# need to store effects here!
# all non in-combat effects are saved here
# not sure how
	

func create_character() -> CombatCharacter:
	var character: CombatCharacter = load("res://player/player.tscn").instantiate()
	character.name = str(id)
	character.health = finishedWithHealth
	character.maxHealth = maxHealth
	character.debug_name = nick
	character.effects = []
	character.set_multiplayer_authority(id)
	print("created player with id=%d" % id)
	return character
	
	
func destroy_character(node: CombatCharacter):
	self.finishedWithHealth = node.health
	node.on_dead()
	node.queue_free()
	
var _first_sync := true
func _on_multiplayer_synchronizer_synchronized():
	if _first_sync:
		_first_sync = false
		GameManager.on_player_state_arrived(self)
