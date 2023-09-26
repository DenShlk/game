extends UiInteraction

@export var text: String = ""
@onready var _label := $player_interaction/CenterContainer/MarginContainer/MarginContainer/RichTextLabel

func _ready():
	_label.add_text(text)
