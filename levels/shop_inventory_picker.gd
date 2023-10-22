extends Node2D

# {price: 10, rarity: 1, scene: scene}
# probability (not normalized) of choosing item is 1/rarity
@export var items: Array[Dictionary]

@onready var stands: Array[ShopStand] = []

var _rng = RandomNumberGenerator.new()


func _ready():
	if !multiplayer.is_server():
		return

	for c in get_children():
		if c is ShopStand:
			stands.append(c)
			
	for s in stands:
		var item := choose_item()
		var node := item['scene'].instantiate() as Interactable
		s.set_item(item['price'], node)
		
func choose_item() -> Dictionary:
	var prob_sum: float = items.map(func (x): return 1.0 / x['rarity']).reduce(func (x, y): return x + y)
	print('choosing!')
	while true:
		for i in items:
			var prob: float = (1.0 / i['rarity']) / prob_sum
			var chance = _rng.randf()
			print('item: ', i, ' threshold: ', prob, ' result: ', chance)
			if chance <= prob:
				print('chosen!')
				return i
	return {}
			
func _get_tool_buttons() -> Array:
	return [add_item]
	
func add_item():
	items.append({
		"price": 10,
		"rarity": 1,
		"scene": load("res://levels/blocks/heart.tscn") as PackedScene,
	})
	notify_property_list_changed()
