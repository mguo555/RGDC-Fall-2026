extends Node
var resource = load("res://dialogue/shopDialogue/shop.dialogue")

@onready var exit_button = $UI/ExitButton

func _ready():
	DialogueManager.show_dialogue_balloon(resource, "greet", [GameManager])

func _process(delta):
	# no walking out in the middle of a conversation
	exit_button.disabled = GameManager.is_dialogue_running

# unhandled so the balloon's own clicks and keys don't reopen the shop
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not GameManager.is_dialogue_running:
		get_viewport().set_input_as_handled()
		DialogueManager.show_dialogue_balloon(resource, "greet", [GameManager])

func _on_exit_button_pressed():
	GameManager.close_shop()
