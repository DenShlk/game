class_name CombatCharacter
extends CharacterBody2D

@export var debug_name = "name"
@export var maxHealth = 100
@export var health = 100
@export var healthBar: HealthBar = null
@export var move_speed_modifier: float = 1

# i want to see it, but don't modify it manually (use add_effect())
@export var _effects: Array[BaseEffect]
		
@export var forces: Array[String]
var force_registry: ForceRegistry = null

signal on_dead

var is_dead: bool = false

func _ready():
	force_registry = get_parent()
	if multiplayer.is_server():
#		synced_id = GameManager.give_id()
#		_set_synced_id.rpc(synced_id)

		for f in forces:
			force_registry.register(get_path(), f)
			
func _physics_process(delta):
	if !multiplayer.is_server():
		return
	_process_effects()
	
func _process_effects():
	var new_effects: Array[BaseEffect] = []
	for e in _effects:
		if e.ended:
			e.on_removed(self)
		else:
			new_effects.append(e)
	_effects = new_effects
		
func add_effect(effect: BaseEffect):
	_effects.append(effect)
	effect.on_added(self)
	_effects.sort_custom(func(x: BaseEffect, y: BaseEffect): 
		return x.priority > y.priority)


func apply_damage(d: Damage) -> Damage:
	assert(multiplayer.is_server(), "must be server to do damage")
	
	for e in _effects:
		if e.has_method('owner_applies_damage'):
			d = e.owner_applies_damage(d)
	return d
	
func receive_damage(d: Damage):
	assert(multiplayer.is_server(), "must be server to take damage")

	if is_dead:
		return
	
	for e in _effects:
		if e.has_method('target_receives_damage'):
			d = e.target_receives_damage(d)
			
	# might want to spawn number here
	print("damage to ", debug_name, ":", d.calc_value())
	health -= d.calc_value()
	receive_damage_vfx.rpc(d.calc_value())
	if healthBar != null:
		healthBar.set_health.rpc(1.0 * health / maxHealth)
	if health <= 0:
		_on_dead()
	
	for e in d.effects:
		add_effect(e)
	
	
var damage_number_vfx: PackedScene = load("res://combat/damage_number.tscn")	
@rpc("any_peer", "call_local", "unreliable", 6)
func receive_damage_vfx(value: int):
	var node = damage_number_vfx.instantiate()
	node.value = value
	add_child(node)


var _interactable_in_range: Interactable
func on_interaction_available(node: Interactable):
	_interactable_in_range = node

func on_interaction_unavailable(node: Interactable):
	if _interactable_in_range == node:
		_interactable_in_range = null

func _on_dead():
	print("%s: i am dead, too bad" % debug_name)
	is_dead = true
	if multiplayer.is_server():
		for f in forces:
			force_registry.unregister(get_path(), f)
	on_dead.emit(self)
			
