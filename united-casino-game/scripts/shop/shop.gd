extends Node
var resource = load("res://dialogue/shopDialogue/shop.dialogue")

var firstBuy = false;

func _ready():
	DialogueManager.show_dialogue_balloon(resource, "greet", [self])
