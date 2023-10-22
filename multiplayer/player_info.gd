extends Node
class_name PlayerInfo

@export var id: int
@export var nick: String
@export var finishedWithHealth: int
@export var money: int
@export var maxHealth: int
@export var weaponPath: String

var upgrades: Array[Upgrade] = []

# need to store effects here!
# all non in-combat effects are saved here
# not sure how


func create_character() -> CombatCharacter:
	var character: PlayerCharacter = load("res://player/player.tscn").instantiate()
	character.name = str(id)
	character.health = finishedWithHealth
	character.maxHealth = maxHealth
	character.debug_name = nick
	character.effects = []
	character.set_multiplayer_authority(id)
	# may be needs to happen after character is ready
	for u in upgrades:
		u.on_player_spawn(character)
	
	print("created player with id=%d" % id)
	return character
	
	
func destroy_character(node: CombatCharacter):
	if node.health <= 0:
		self.maxHealth = maxi(10, self.maxHealth / 2)
		self.finishedWithHealth = self.maxHealth
	else:
		self.finishedWithHealth = node.health
#	node.on_dead()
	node.queue_free()
	await node.tree_exited
	print('should exit')
	
var _first_sync := true
func _on_multiplayer_synchronizer_synchronized():
	if _first_sync:
		_first_sync = false
		GameManager.on_player_state_arrived(self)
	
		
@onready var upgrades_root := $upgrades

func add_upgrade(upgrade: Upgrade):
	upgrades_root.add_child(upgrade, true)

func _on_upgrades_child_entered_tree(node):
	if multiplayer.is_server():
		upgrades.append(node as Upgrade)


func _on_upgrades_child_exiting_tree(node):
	if multiplayer.is_server():
		upgrades.erase(node as Upgrade)
