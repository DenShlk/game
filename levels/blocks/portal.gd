extends ServerInteractable

@export var destination_level: PackedScene
@export var duplicate_level := false

func _ready():
	super()
	assert(destination_level != null, "no destination set!")
	

func interact(node: CombatCharacter):
	if node is PlayerCharacter:
		super(node)


func _interact(node: CombatCharacter):
	if node is PlayerCharacter:
		var info: PlayerInfo = node.player_info
		
		# need to make sure it's destoroyed in case we teleport to same level
		await info.destroy_character(node)
		
		print('teleporting node by path: %s' % node.get_path())
		var level: BaseLevel = null
		if duplicate_level:
			level = destination_level.instantiate()
			LevelLoader.AddLevel(level)
		else:
			level = LevelLoader.add_level_unless_exists(destination_level)
		LevelLoader.MovePlayer(info.create_character(), level)
	else:
		assert(false, "not player nodes should be here")
		
