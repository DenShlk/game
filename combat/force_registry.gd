class_name ForceRegistry
extends Node2D

# need to sync:
# string -> Dict[NodePath, bool] (no set) (no dict typing yet)
var forces: Dictionary = {}
# NodePath -> Dict[force_name, true]
var entities: Dictionary = {}


# you can register to multiple forces!

func register(who: NodePath, force: String):
	assert(multiplayer.is_server(), "must be server to edit forces")
	_register.rpc(who, force)

@rpc("authority", "call_local", "reliable", 2)
func _register(who: NodePath, force: String):
	if not forces.has(force):
		forces[force] = {}
	
	forces[force][who] = true
	if !entities.has(who):
		entities[who] = {force: true}
	else:
		entities[who][force] = true

func unregister(who: NodePath, force: String):
	assert(multiplayer.is_server(), "must be server to edit forces")
	_unregister.rpc(who, force)
	
@rpc("authority", "call_local", "reliable", 2)
func _unregister(who: NodePath, force: String):
	if not entities.has(who) || not forces.has(force):
		return

	forces[force].erase(who)
	var d: Dictionary = entities[who]
	if d.has(force):
		d.erase(force)
		if d.size() == 0:
			entities.erase(who)

# if you have common force, you are allies. entities without force are passive
# why passive? well, for example synced_id is not instantly ready, so characters should wait until it is sent to them doing nothing.
# think what happend after synced_id deprecation
func is_enemy(you: NodePath, other: NodePath) -> bool:
	if !entities.has(you) || !entities.has(other):
		return false
	var other_allies: Dictionary = entities[other]
	var allies: Dictionary = entities[you]
	
	for a in allies.keys():
		if other_allies.has(a):
			return false
	return true
	
# returns array of sets of enemy entities
func get_enemies(you: NodePath) -> Array[Dictionary]:
	var enemies: Array[Dictionary] = []
	var ally_forces: Dictionary = entities[you]
	
	for f in forces:
		if ally_forces.has(f):
			continue
		
		enemies.append(forces[f])
	return enemies
	
