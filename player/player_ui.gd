extends Camera2D

@onready var money : Label= $CanvasLayer/VBoxContainer2/MarginContainer2/money_label
@onready var healthbar := $CanvasLayer/VBoxContainer2/MarginContainer/HBoxContainer2/CenterContainer/healthbar
@onready var health_text := $CanvasLayer/VBoxContainer2/MarginContainer/HBoxContainer2/health_label
@onready var multiplayer_id_text := $CanvasLayer/VBoxContainer/MarginContainer2/CenterContainer/multiplayer_id_label

@onready var _player: PlayerCharacter = get_parent()

func _ready():
	set_multiplayer_authority(_player.name.to_int())
	
	enabled = is_multiplayer_authority()
	process_mode = Node.PROCESS_MODE_INHERIT if is_multiplayer_authority() else Node.PROCESS_MODE_DISABLED
	if !is_multiplayer_authority():
		hide()
		$CanvasLayer.hide()
		

func _process(delta):
	money.text = "%d$" % _player.player_info.money
	healthbar.max_value = _player.maxHealth
	healthbar.value = _player.health
	health_text.text = "%d/%d" % [_player.health, _player.maxHealth]
	multiplayer_id_text.text = str(get_multiplayer_authority())
