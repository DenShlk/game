extends CombatCharacter

@export var running_speed: float = 100
@export var attack_speed: float = 1000
@export var attack_distance: float = 150

@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var rest_timer = $RestTimer
@onready var retarget_timer = $RetargetTimer
@onready var attack_timer = $AttackTimer
@onready var disappear_timer = $DisappearTimer
@onready var sprite: Sprite2D = $Sprite2D

@onready var hitbox: StaticWeapon = $static_weapon

var target: Vector2 = Vector2.ZERO

func _ready():
	super()
	$AnimationTree.active = is_multiplayer_authority()
	
func _process(delta):
	if !multiplayer.is_server():
		return
		
	if state_machine.get_current_node() != "auto_attack" and rest_timer.is_stopped():
		sprite.flip_h = position.direction_to(target).x > 0

var _last_state: String = ""
func _physics_process(_delta):
	if !multiplayer.is_server():
		return
	if is_dead:
		return
	
	move_and_slide()
	
	var state_changed: bool = _last_state != state_machine.get_current_node()
	_last_state = state_machine.get_current_node()
	# print("current state: ", _last_state)
	match state_machine.get_current_node():
		"auto_idle":
			velocity = Vector2.ZERO
			if !rest_timer.is_stopped():
				return
			find_target()
			if target != Vector2.ZERO:
				state_machine.travel("auto_run")
		"auto_run":
			find_target()
			if target == Vector2.ZERO:
				state_machine.travel("auto_idle")
				return
			velocity = to_target() * running_speed
			if target.distance_to(position) < attack_distance:
				state_machine.travel("auto_charge")
		"auto_charge":
			velocity = Vector2.ZERO
		"auto_attack":
			if state_changed:
				attack_timer.start()
				velocity = to_target() * attack_speed
				hitbox.toggle(true)
			if attack_timer.is_stopped():
				state_machine.travel("auto_idle")
				rest_timer.start()
				hitbox.toggle(false)
	
	# print(_last_state, ' - ', velocity)
		
	
func find_target():
	if !retarget_timer.is_stopped():
		return
	
	retarget_timer.start()
	self.target = Vector2.ZERO
		
	var closest = null
	var closest_dist = 1e9
	for enemies in force_registry.get_enemies(self.get_path()):
		for node_path in enemies:
			var node: Node2D = get_node(node_path)
			var dist = (position - node.position).length()
			if dist < closest_dist:
				closest = node
				closest_dist = dist
	if closest != null:
		self.target = closest.position
	
func to_target() -> Vector2:
	return position.direction_to(target)
	
func on_dead():
	super()
	
	state_machine.travel("auto_dead")
	velocity = Vector2.ZERO
	hitbox.toggle(false)
	disappear_timer.start()
	print("dead: ", self)
	
