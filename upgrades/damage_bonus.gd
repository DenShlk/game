extends Upgrade

@export var delta: int = 5

class DamageBonusEffect:
	extends BaseEffect
	
	var delta: int
	func _init(delta: int):
		self.delta = delta
	
	func owner_applies_damage(d: Damage) -> Damage:
		d.base += delta
		return d

func on_player_spawn(player: PlayerCharacter):
	player.effects.append(DamageBonusEffect.new(delta))
