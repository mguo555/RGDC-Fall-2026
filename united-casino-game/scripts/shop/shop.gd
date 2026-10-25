extends Node
var resource = load("res://dialogue/shopDialogue/shop.dialogue")
var normalMusic = load("res://assets/music/normal-background-music.mp3")


@onready var exit_button = $UI/ExitButton
@onready var talk_hint = $UI/TalkHint

func _ready():
	DialogueManager.show_dialogue_balloon(resource, "greet", [GameManager])

func _process(delta):
	# no walking out in the middle of a conversation
	exit_button.disabled = GameManager.is_dialogue_running
	talk_hint.visible = not GameManager.is_dialogue_running

# unhandled so the balloon's own clicks and keys don't reopen the shop
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not GameManager.is_dialogue_running:
		get_viewport().set_input_as_handled()
		DialogueManager.show_dialogue_balloon(resource, "greet", [GameManager])

func _on_exit_button_pressed():
	SoundManager.music_player.volume_db = -15
	SoundManager.play_music(normalMusic)
	GameManager.close_scene()
