extends Interactable

@export var text: String = "This message is not supported by your version of Telegram. Please update to the latest version in Settings > Advanced, or install it from https://desktop.telegram.org. If you are already using the latest version, this message might depend on a feature that is not yet implemented.."
var _tablet_ui: PackedScene = load("res://levels/blocks/tablet/tablet_ui.tscn")

func _interact(node: CombatCharacter):
	if node is PlayerCharacter:
		var ui: UiInteraction = _tablet_ui.instantiate()
		ui.text = text
		node.enter_ui(ui)
		await ui.interaction_end
		node.leave_ui(ui)
