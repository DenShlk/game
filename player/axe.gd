extends BaseWeapon

@onready var state_machine = $AnimationTree.get("parameters/playback")
@onready var hitbox = $Origin/Axe/DirectHitArea/CollisionPolygon2D

func _ready():
	super()
#	$AnimationTree.active = is_multiplayer_authority()
	hitbox.disabled = true


@rpc("any_peer", "call_local", "unreliable", 4)
func attack(direction: Vector2):
	rotation = direction.angle()
	match (state_machine.get_current_node()):
		"RESET":
			state_machine.travel('attack_1')
		"before attack 2":
			state_machine.travel('attack_2')
		"before attack 3":
			state_machine.travel('attack_3')


func _process(delta):
	if !multiplayer.is_server():
		return
	
	match (state_machine.get_current_node()):
		"RESET", "before attack 2", "before attack 3":
			hitbox.disabled = true
		"attack_1", "attack_2", "attack_3":
			hitbox.disabled = false
	

func _on_direct_hit_area_body_entered(body: Node):
	_on_hit(body)
