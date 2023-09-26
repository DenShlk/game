class_name StaticWeapon
extends BaseWeapon

var hitboxes: Array[CollisionShape2D]

func _ready():
	super()
	for child in get_children():
		if child is CollisionShape2D:
			hitboxes.append(child)

func toggle(enable: bool):
	for h in hitboxes:
		h.disabled = !enable
		
