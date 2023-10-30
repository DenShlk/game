class_name BaseEffect
extends Node

@export var priority: int
var ended := false
# below are methods you can override to do something
# they are commented to not pass checks

#func owner_applies_damage(d: Damage) -> Damage:
#	return null
#
#func owner_applies_damage(d: Damage) -> Damage:
#	return null
func on_added(character: CombatCharacter):
	pass
	
func on_removed(character: CombatCharacter):
	pass
