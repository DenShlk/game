class_name BaseWeapon
extends Node2D

@export var character: CombatCharacter
@export var effects: Array[BaseEffect]

@export var baseDamage: int

func _ready():
	if character == null && get_parent() is CombatCharacter:
		character = get_parent()
	assert(character != null, "no character set")
	# todo: disable collision shape on clients

func _on_hit(body: Node):
	if multiplayer.is_server():
		if body != character && body is CombatCharacter: #.has_method('receive_damage'):
			if character.force_registry.is_enemy(character.get_path(), body.get_path()):
				body.receive_damage(create_damage())
		
func create_damage() -> Damage:
	assert(multiplayer.is_server(), "must be server to create damage")
	
	var d: Damage = Damage.new(baseDamage)
	
	d = character.apply_damage(d)
	for e in effects:
		if e.has_method('apply_damage'):
			d = e.apply_damage(d)
	return d
