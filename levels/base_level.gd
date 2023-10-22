class_name BaseLevel
extends Node2D

@export var seed: int = -1

@onready var force_registry: ForceRegistry = $ForceRegistry
@onready var player_spawn: Node2D = $player_spawn

var random = RandomNumberGenerator.new()
var ended = false
	
func _ready():
	assert(force_registry != null, "force registry not found")
	assert($MultiplayerSpawner != null, "multiplayer spawner not found")
	
	if !multiplayer.is_server():
		return
		
	start_level()
		
func _process(delta):
	if !multiplayer.is_server() || ended:
		return
		
	if !force_registry.are_opponents_present():
		if !next_wave():
			end_level()
		
func add_player(node: PlayerCharacter):
	_add_character(node)
	node.position = player_spawn.position
	node.on_dead.connect(_player_dead)
		
		
func _add_character(node: CombatCharacter):
	if !self.is_node_ready(): # how can it be ready if it's not in tree???
		await ready
	force_registry.add_child(node, true)

# to implement:

func start_level():
	print("starting level")
	
func next_wave() -> bool:
	print("spawning next wave (or not)")
	return false

func end_level():
	ended = true
	print("ending level")

func _player_dead(player: PlayerCharacter):
	print("player died, how sad...")
