extends Node2D



func _ready():
	var level_loader: LevelLoader = load("res://levels/level_loader.tscn").instantiate()
	
	level_loader.mobs.append(load("res://combat/boar.tscn"))
	level_loader.weights.append(1)
	level_loader.budget = GameManager.get_players_count() * 2
	level_loader.seed = GameManager.get_seed()
	
	add_child(level_loader)
