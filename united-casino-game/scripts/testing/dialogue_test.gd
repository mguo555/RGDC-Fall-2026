extends Node

var resource = load("res://testDialogue/testGreet.dialogue")
var isTrue: bool = true

func _ready():
	DialogueManager.show_dialogue_balloon(resource, "testBool", [self])
