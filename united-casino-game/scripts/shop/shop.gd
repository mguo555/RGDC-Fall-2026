extends Node
var resource = load("res://dialogue/shopDialogue/shop.dialogue")

# unhandled so the balloon's own clicks and keys don't reopen the shop
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not GameManager.is_dialogue_running:
		get_viewport().set_input_as_handled()
		DialogueManager.show_dialogue_balloon(resource, "greet", [GameManager])
