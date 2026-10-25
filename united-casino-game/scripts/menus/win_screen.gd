extends Control
var resource = load("res://dialogue/win.dialogue")

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(resource, "start", [GameManager])

# "YOU'RE FREE" shows up once Mr. Shady is done
func _on_dialogue_ended(_resource):
	$WinLabel.show()
	$QuitButton.show()

func _on_quit_button_pressed():
	get_tree().quit()
