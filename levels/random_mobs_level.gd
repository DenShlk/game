extends BaseLevel

@export var mobs: Array[PackedScene] = []
@export var weights: Array[int] = []
@export var budget: int = 0
@export var spawn_offset = 30.0

# actually, node2d but idk how to do it
@onready var mob_spawns: Array[Node] = $mob_spawns.get_children()

func _ready():
	super()
	if !multiplayer.is_server():
		return
		
	assert(mobs.size() > 0, "no mobs provided!")
	assert(mobs.size() == weights.size(), "count of mobs and weights must be equal")
	random.seed = randi() if seed == -1 else seed
	print('generating level by seed: ', random.seed)
	spawn_mobs(choose_mobs())

func choose_mobs() -> Array[PackedScene]:
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
	
func spawn_mobs(mobs: Array[PackedScene]):
	for m in mobs:
		var node: Node2D = m.instantiate()
		_add_character(node)
		node.position = _random_position()
		
func _random_position() -> Vector2:
	return mob_spawns.pick_random().position + \
		Vector2.from_angle(PI * 2 * randf()) * spawn_offset
