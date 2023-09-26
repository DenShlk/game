class_name Interactable
extends Node2D

# base class for interactable objects (labels, portals, whatever)
# you need to set interaction area for it to work, when combat character enters
# it, it will be able to interact with this.
# you can set turn it on/off  (not yet)
# areas of interactables, shouldn't intersect (but it's not too bad)

@export var interaction_area: Area2D

func _ready():
	interaction_area.body_entered.connect(body_entered)
	interaction_area.body_exited.connect(body_exited)	


# no need to call super for now
func interact(character: CombatCharacter):
	# do something
	print("you did something, must be cool!")
	
	
func body_entered(body: Node2D):
	if body is CombatCharacter:
		body.on_interaction_available(self)
	
	
func body_exited(body: Node2D):
	if body is CombatCharacter:
		body.on_interaction_unavailable(self)
 
