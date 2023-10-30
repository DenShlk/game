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
@onready var navigation: NavigationAgent2D = $NavigationAgent2D

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
func _physics_process(delta):
	super(delta)
	if !multiplayer.is_server():
		return
	if is_dead:
		return
	
	var to_target := to_local(navigation.get_next_path_position())
	
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
			var direction := to_target.normalized()
			velocity = direction * running_speed
			if navigation.distance_to_target() < attack_distance and \
					to_local(navigation.get_final_position()) == to_target:
				# if in reach and we are going to the last waypoint
				state_machine.travel("auto_charge")
		"auto_charge":
			velocity = Vector2.ZERO
		"auto_attack":
			if state_changed:
				attack_timer.start()
				velocity = to_target.normalized() * attack_speed
				hitbox.toggle(true)
			if attack_timer.is_stopped():
				state_machine.travel("auto_idle")
				rest_timer.start()
				hitbox.toggle(false)
	
	move_and_collide(velocity * delta)
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
			var dist = to_local(node.global_position).length()
			if dist < closest_dist:
				closest = node
				closest_dist = dist
	if closest != null:
		self.target = closest.global_position
		navigation.target_position = self.target
	
func _on_dead():
	super()
	
	state_machine.travel("auto_dead")
	velocity = Vector2.ZERO
	hitbox.toggle(false)
	disappear_timer.start()
	print("dead: ", self)
	
