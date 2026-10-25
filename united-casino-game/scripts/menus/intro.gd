extends Control
var resource = load("res://dialogue/intro.dialogue")

func _ready():
	# Mr. Shady walks in from the right, then the talking starts
	var tween = create_tween()
	tween.tween_property($MrShady, "position:x", 1320.0, 1.2)
	await tween.finished
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(resource, "start", [GameManager])

func _on_dialogue_ended(_resource):
	GameManager.intro_done()
