extends ServerInteractable
class_name ShopStand

@export var price: int = 10:
	set = set_price
@export var thing: Interactable

@onready var price_label := $CenterContainer/Label

# syncing this is questionable, for example thing is set only for server
func set_item(_price: int, item: Interactable):
	price = _price
	thing = item
	add_child(thing, true)
	thing.set_enabled(false)
	

func set_price(_price: int):
	price = _price
	price_label.text = "%d$" % price


func interact(character: CombatCharacter):
	if character is PlayerCharacter:
		super(character)


func _interact(character: CombatCharacter):
	var player := character as PlayerCharacter
	if thing != null:
		if player.player_info.money >= price:
			player.player_info.money -= price
			thing.set_enabled(true)
			thing.interact(character) # too bad if it doesn't want to interact...
			thing = null
			set_enabled(false, true)
			

func _set_enabled_local(enabled: bool):
	print(multiplayer.get_unique_id(), ' - set enabled override: ', enabled)
	if !enabled:
		price_label.hide()
		if thing:
			thing.hide()
	else:
		price_label.show()
		if thing:
			thing.show()
	
