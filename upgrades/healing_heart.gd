extends ServerInteractable

@export var bonusHealth: int = 25

var _used := false
func _interact(character: CombatCharacter):
	if !_used:
		_used = true
		character.health = min(character.maxHealth, character.health + bonusHealth)
		queue_free()
