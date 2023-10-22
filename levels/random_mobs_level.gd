extends BaseLevel

@export var mobs: Array[PackedScene] = []
@export var weights: Array[int] = []
@export var budget: int = 0
@export var spawn_offset = 30.0

# actually, node2d but idk how to do it
@onready var mob_spawns: Array[Node] = $mob_spawns.get_children()

	
func start_level():
	assert(mobs.size() > 0, "no mobs provided!")
	assert(mobs.size() == weights.size(), "count of mobs and weights must be equal")
	random.seed = randi() if seed == -1 else seed
	print('generating level by seed: ', random.seed)
	
	_spawn_mobs(_choose_mobs())


func _choose_mobs() -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	var weight_sum = weights.reduce(func(x, y): x + y) * 1.0
	var spent = 0
	
	while spent < budget:
		var chosen: bool = false
		while !chosen:
			for i in range(mobs.size()):
				if random.randf() <= (weights[i] / weight_sum):
					result.append(mobs[i])
					spent += weights[i]
					chosen = true
					break
	return result
	
	
func _spawn_mobs(mobs: Array[PackedScene]):
	for m in mobs:
		var node: Node2D = m.instantiate()
		_add_character(node)
		node.position = _random_position()
		
		
func _random_position() -> Vector2:
	return mob_spawns.pick_random().position + \
		Vector2.from_angle(PI * 2 * randf()) * spawn_offset

@export var reward: int = 50
@export var reward_position: Node2D
var _reward_scene: PackedScene = load("res://levels/blocks/coin.tscn")
func end_level():
	var scene := _reward_scene.instantiate()
	scene.position = reward_position.position
	scene.amount = reward
	$Destoryables.add_child(scene, true)
	
	super()
	
	await scene.tree_exited
	if get_tree() == null:
		return
		
	await get_tree().create_timer(1.0).timeout
	for character in force_registry.get_children():
		if character is PlayerCharacter:
#			var lobby := LevelLoader.FindLevel(load("res://levels/starting_area.tscn"))
#			LevelLoader.MovePlayer(character.player_info.create_character(), lobby)
			var scenario := ScenarioManager.get_scenario(character.player_info.id) as Scenario
			scenario.on_clear(self, character)
			

func _player_dead(player: PlayerCharacter):
	await get_tree().create_timer(5).timeout
	var scenario := ScenarioManager.get_scenario(player.player_info.id) as Scenario
	scenario.on_death(self, player)
