@tool
class_name Interactable
extends Node2D

# base class for interactable objects (labels, portals, whatever)
# you need to set interaction area for it to work, when combat character enters
# it, it will be able to interact with this.
# you can set turn it on/off  (not yet)
# areas of interactables, shouldn't intersect (but it's not too bad)
		
@export var interaction_area: Area2D

var _enabled := true

# something doesn't work? do you call super in ready?
func _ready():
	interaction_area.body_entered.connect(body_entered)
	interaction_area.body_exited.connect(body_exited)	


func _exit_tree():
	set_enabled(false)

# combat character calls it, you can make checks here whether to call _interact
func interact(character: CombatCharacter):
	if _enabled:
		_interact(character)
	else:
		print(character, " tried to interact with disabled ", self)
	
	
func set_enabled(enabled: bool):
	_enabled = enabled
	for body in interaction_area.get_overlapping_bodies():
		if body is CombatCharacter:
			if _enabled:
				body.on_interaction_available(self)
			else:
				body.on_interaction_unavailable(self)

# do actual interaction
func _interact(character: CombatCharacter):
	# do something
	print("you did something, must be cool!")
	
	
func body_entered(body: Node2D):
#	print(self, " - body entered ", body)
	if _enabled and body is CombatCharacter:
		body.on_interaction_available(self)
	
	
func body_exited(body: Node2D):
	if body is CombatCharacter:
		body.on_interaction_unavailable(self)
		

		
func _get_configuration_warnings() -> PackedStringArray:
	print('hello there!')
	if not interaction_area:
		return ['Interaction area isn\'t set']
	return []

