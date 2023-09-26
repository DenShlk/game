class_name BaseLevel
extends Node2D

@export var seed: int = -1

@onready var force_registry: ForceRegistry = $ForceRegistry
@onready var player_spawn: Node2D = $player_spawn

var random = RandomNumberGenerator.new()
	
func _ready():
	assert(force_registry != null, "force registry not found")
	assert($MultiplayerSpawner != null, "multiplayer spawner not found")
	
	if !multiplayer.is_server():
		return
		
		
func add_player(node: CombatCharacter):
	_add_character(node)
	node.position = player_spawn.position
		
		
func _add_character(node: CombatCharacter):
	if !self.is_node_ready():
		await ready
	force_registry.add_child(node, true)
