extends BaseLevel

#func start_level():
#	print("starting level")
#
#func next_wave() -> bool:
#	print("spawning next wave (or not)")
#	return false
#
#func end_level():
#	ended = true
#	print("ending level")

func _player_dead(player: PlayerCharacter):
	var scenario := ScenarioManager.get_scenario(player.player_info.id) as Scenario
	scenario.on_death(self, player)
