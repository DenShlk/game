extends Node
class_name Scenario
# for now to deal with multiple characters, simply call methods for all of them:)
# first level is starting area - players will be returned to it when die
@export var levels: Array[PackedScene]

var player2level_idx: Dictionary = {}
var player2max_level_idx: Dictionary = {}

func _move_to_level(player: PlayerCharacter, idx: int):
	var info := player.player_info
	await info.destroy_character(player)
	_add_to_level(info.create_character(), idx)
	

func _add_to_level(player: PlayerCharacter, idx: int):
	var level: BaseLevel
	if idx == 0: # levels identification and creation needs a rework
		level = LevelLoader.add_level_unless_exists(levels[idx])
	else:
		level = levels[idx].instantiate()
		LevelLoader.AddLevel(level)
	player2level_idx[player.name] = idx
	player2max_level_idx[player.name] = maxi(idx, player2max_level_idx[player.name])
	LevelLoader.MovePlayer(player, level)


func add_player(info: PlayerInfo):
	player2max_level_idx[info.name] = 0
	_add_to_level(info.create_character(), 0)

# goes to next level
func on_clear(level: BaseLevel, player: PlayerCharacter):
	var next_level_idx = player2level_idx[player.name] + 1
	
	if next_level_idx < levels.size():
		_move_to_level(player, next_level_idx)
	else:
		print("last level, what to do?")
		_move_to_level(player, 0)
	

# returns to save point or something
func on_death(level: BaseLevel, player: PlayerCharacter):
	_move_to_level(player, 0)

# wtf?
func revive(info: PlayerInfo):
	_add_to_level(info.create_character(), player2max_level_idx[info.name])
	
