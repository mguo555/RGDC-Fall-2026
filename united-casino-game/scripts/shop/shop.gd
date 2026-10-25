extends Node
var resource = load("res://dialogue/shopDialogue/shop.dialogue")
@onready var game_manager = $".."

# true until the player buys something for the first time
var firstBuy = true
var isInteract = false

func _ready():
	pass

func _process(delta: float) -> void:
	if isInteract == true:
		interact()
	if Input.is_action_just_pressed("interact"):
		isInteract = true

func interact():
	DialogueManager.show_dialogue_balloon(resource, "greet", [game_manager])
	isInteract = false
