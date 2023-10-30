extends ServerInteractable

@export var upgrade_scene: PackedScene

var _used := false
func _interact(character: CombatCharacter):
	if character is PlayerCharacter:
		if _used:
			return
		_used = true

		character.player_info.add_upgrade(upgrade_scene.instantiate(), character)
		queue_free()
