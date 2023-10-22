extends Interactable
class_name ProxyInteractable

@export var target: Interactable

func _ready():
	# do not call super(), because we don't have area
	assert(target != null, "no target for proxy interactable")

func set_enabled(enabled: bool):
	target.set_enabled(enabled)

func interact(character: CombatCharacter):
	target.interact(character)
	
