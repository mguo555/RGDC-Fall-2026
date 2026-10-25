extends Node
var resource = load("res://dialogue/shopDialogue/shop.dialogue")

# true until the player buys something for the first time
var firstBuy = true

func _ready():
	DialogueManager.show_dialogue_balloon(resource, "greet", [self])
