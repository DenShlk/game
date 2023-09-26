extends Control
class_name UiInteraction

signal interaction_end

func _process(delta):
	# need to think about nested ui-s, when you press back to go to previous one
	if Input.is_action_just_pressed("back"):
		interaction_end.emit()
		
