extends ServerInteractable

@onready var level := $".." as BaseLevel

func interact(node: CombatCharacter):
	if node is PlayerCharacter:
		super(node)

func _interact(node: CombatCharacter):
	if node is PlayerCharacter:
		var scenario = $"/root/ScenarioManager/Scenarios/SimpleScenario"
		scenario.on_clear(level, node)
	else:
		assert(false, "not player nodes should be here")
	
