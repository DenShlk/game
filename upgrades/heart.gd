extends ServerInteractable

@export var bonusHealth: int = 25

var _used := false
func _interact(character: CombatCharacter):
	if !_used:
		_used = true
		character.maxHealth += bonusHealth
		character.health += bonusHealth
		if character is PlayerCharacter:
			character.player_info.maxHealth += bonusHealth
		queue_free()
