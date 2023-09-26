class_name PlayerCharacter
extends CombatCharacter

@export var speed: float = 250
@export var dash_speed: float = speed * 2.25
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

@export var weapon: BaseWeapon = null

@export var sprite: Sprite2D

@onready var dash_cooldown_timer = $DashCooldown
@onready var dash_duration_timer = $DashDuration
var _last_moving_direction: Vector2 = Vector2.ZERO

@onready var state_machine = $AnimationTree.get("parameters/playback")

var player_info: PlayerInfo

var _in_ui := false

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	$ServerSynchronizer.set_multiplayer_authority(1)
	
# you need to set authority to right player!
func _ready():
	$AnimationTree.active = is_multiplayer_authority()
	if is_multiplayer_authority() or multiplayer.is_server():
		player_info = GameManager.get_player_info_by_id(get_multiplayer_authority())
	
	if multiplayer.is_server():
		forces.append(player_info.nick)
		
	print('i am player by control of %d i am in %d game' % [get_multiplayer_authority(), multiplayer.get_unique_id()])
	super()


func _get_input():
	if _in_ui:
		return
		
	_process_movement()
	if dash_duration_timer.is_stopped():
		_process_attacks()
	if Input.is_action_just_pressed("interact") and _interactable_in_range != null:
		_interactable_in_range.interact(self)
		
	
func _process_attacks():
	if weapon != null and Input.is_action_just_pressed("attack"):
		weapon.attack.rpc(_last_moving_direction)
		
func _process_movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	if !input_direction.length() == 0:
		_last_moving_direction = input_direction
	
	if dash_cooldown_timer.is_stopped() and Input.get_action_strength("dash") != 0:
		dash_cooldown_timer.start(dash_cooldown)
		dash_duration_timer.start(dash_duration)
	if !dash_duration_timer.is_stopped():
		velocity = _last_moving_direction * dash_speed
		state_machine.travel("dash")
	elif velocity.length() == 0:
		state_machine.travel("idle")
	else:
		state_machine.travel("walk")
	if state_machine.get_current_node() == "walk":
		sprite.flip_h = _last_moving_direction.x < 0
	

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if is_dead:
		return
	
	_get_input()
	move_and_slide()
	
func on_dead():
	super()
	state_machine.travel("die")
	
func enter_ui(ui: Control):
	_in_ui = true
	$Camera2D/CanvasLayer.add_child(ui)
	
func leave_ui(ui: Control):
	$Camera2D/CanvasLayer.remove_child(ui)
	_in_ui = false
	
