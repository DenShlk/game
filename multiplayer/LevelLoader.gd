extends Node

var levels: Array[BaseLevel] = []
const LEVEL_OFFSET: int = 500
var level_idx: int = 0

func FindLevel(scene: PackedScene) -> BaseLevel:
	for l in levels:
		if l.scene_file_path == scene.resource_path:
			return l
	return null
		

func AddLevel(scene: BaseLevel):
	assert(multiplayer.get_unique_id() == 1, "only server is allowed to create levels")
	$levels.add_child(scene, true)
	scene.position = Vector2.DOWN * level_idx * LEVEL_OFFSET
	level_idx += 1
	_on_levels_child_entered_tree(scene) # they probably call MoveCharacter right away
	
# no parametrization is being done!
func add_level_unless_exists(scene: PackedScene) -> BaseLevel:
	var level := FindLevel(scene)
	if level == null:
		level = scene.instantiate()
		AddLevel(level)
	return level
	
# currently i'm not sure what will happen if you actually 'move' player from 
# one level to another. So i recreate them.
func MovePlayer(node: CombatCharacter, level: BaseLevel):
	assert(multiplayer.get_unique_id() == 1, "only server is allowed to move characters")
	if !level.is_node_ready():
		await level.ready
	level.add_player(node)
	

func _on_levels_child_entered_tree(node):
	if node is BaseLevel and !levels.has(node):
		levels.append(node)


func _on_levels_child_exiting_tree(node):
	if node is BaseLevel and levels.has(node):
		levels.erase(node)
