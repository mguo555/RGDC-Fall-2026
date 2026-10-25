extends Control
var resource = load("res://dialogue/game_over.dialogue")

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(resource, "start", [GameManager])

# "GAME OVER" shows up once Mr. Shady is done
func _on_dialogue_ended(_resource):
	$GameOverLabel.show()
	$QuitButton.show()
	$MenuButton.show()

func _on_menu_button_pressed():
	GameManager.back_to_menu()

func _on_quit_button_pressed():
	get_tree().quit()
