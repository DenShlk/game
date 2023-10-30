extends Interactable
class_name ProxyInteractable

@export var target: Interactable

func _ready():
	# do not call super(), because we don't have area
	assert(target != null, "no target for proxy interactable")
	target.tree_exited.connect(target_exited)

func set_enabled(enabled: bool):
	if target != null:
		target.set_enabled(enabled)

func interact(character: CombatCharacter):
	target.interact(character)
	
func target_exited():
	queue_free()
