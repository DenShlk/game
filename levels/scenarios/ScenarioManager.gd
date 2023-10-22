extends Node

@onready var scenarios_root := $Scenarios

#var _player2scenario: Dictionary = {}

func get_scenario(player_id: int) -> Scenario:
	return $Scenarios/SimpleScenario
