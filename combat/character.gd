class_name CombatCharacter
extends CharacterBody2D

@export var debug_name = "name"
@export var maxHealth = 100
@export var health = 100
@export var healthBar: HealthBar = null

@export var effects: Array[BaseEffect]

# DEPRECATED!!!
@export var synced_id: int = -123: # id which is the same for all peers
	set(value):
		if synced_id != value:
			GameManager.id2node[value] = self
			synced_id = value
		
@export var forces: Array[String]
var force_registry: ForceRegistry = null

var is_dead: bool = false

func _ready():
	force_registry = get_parent()
	if multiplayer.is_server():
#		synced_id = GameManager.give_id()
#		_set_synced_id.rpc(synced_id)
			
		for f in forces:
			force_registry.register(get_path(), f)
		

func apply_damage(d: Damage) -> Damage:
	assert(multiplayer.is_server(), "must be server to do damage")
	
	for e in effects:
		if e.has_method('owner_applies_damage'):
			d = e.owner_applies_damage(d)
	return d
	
func receive_damage(d: Damage):
	assert(multiplayer.is_server(), "must be server to take damage")

	if is_dead:
		return
	
	for e in effects:
		if e.has_method('target_receives_damage'):
			d = e.target_receives_damage(d)
			
	# might want to spawn number here
	print("damage to ", debug_name, ":", d.calc_value())
	health -= d.calc_value()
	if healthBar != null:
		healthBar.set_health.rpc(1.0 * health / maxHealth)
	if health <= 0:
		on_dead()
	
	effects.append_array(d.effects)
	# call event on_added on new effects
	effects.sort_custom(func(x: BaseEffect, y: BaseEffect): 
		return x.priority > y.priority)

var _interactable_in_range: Interactable
func on_interaction_available(node: Interactable):
	_interactable_in_range = node

func on_interaction_unavailable(node: Interactable):
	if _interactable_in_range == node:
		_interactable_in_range = null

func on_dead():
	print("%s: i am dead, too bad" % debug_name)
	is_dead = true
	if multiplayer.is_server():
		for f in forces:
			force_registry.unregister(get_path(), f)
			

@rpc("any_peer", "call_remote", "reliable", 2)
func _set_synced_id(id: int):
	synced_id = id
