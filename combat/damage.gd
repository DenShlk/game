class_name Damage
extends RefCounted

# accumulate all data concerning particular hit here

var base: int
var modifier: int
var effects: Array[BaseEffect]

func _init(base: int, modifier: int = 0, effects: Array[BaseEffect] = []):
	self.base = base
	self.modifier = modifier
	self.effects = effects

func calc_value() -> int:
	return base * (100 + modifier) / 100
