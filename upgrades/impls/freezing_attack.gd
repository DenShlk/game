extends Upgrade

@export var damage_bonus: int = 1
@export var slowdown: float = 0.5
@export var duration: float = 5
@export var max_stack: int = 10

class FreezingWeaponEffect:
	extends BaseEffect
	
	var damage_bonus: int
	var slowdown: float
	var duration: float
	func _init(damage_bonus: int, slowdown: float, duration: float):
		self.damage_bonus = damage_bonus
		self.slowdown = slowdown
		self.duration = duration
	
	func owner_applies_damage(d: Damage) -> Damage:
		d.base += damage_bonus
		d.effects.append(FreezedEffect.new(slowdown, duration))
		return d

class FreezedEffect:
	extends BaseEffect
	
	var slowdown: float
	func _init(slowdown: float, duration: float):
		self.slowdown = slowdown
		wait_to_end(duration)
		
	func wait_to_end(duration: float):
		await GlobalUtils.wait(duration)
		self.ended = true
		
	func on_added(character: CombatCharacter):
		character.move_speed_modifier *= slowdown
		character.modulate.r /= 2
		character.modulate.g /= 2
		character.modulate.b *= 2
		
	func on_removed(character: CombatCharacter):
		character.move_speed_modifier /= slowdown
		character.modulate.r *= 2
		character.modulate.g *= 2
		character.modulate.b /= 2
		

func on_player_spawn(player: PlayerCharacter):
	player.add_effect(FreezingWeaponEffect.new(damage_bonus, slowdown, duration))

