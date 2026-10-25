extends CanvasLayer

# ESC pauses the game. resume, or exit to the menu (that run is lost)

func _input(event):
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		set_paused(not get_tree().paused)

func set_paused(paused):
	get_tree().paused = paused
	visible = paused

func _on_resume_button_pressed():
	set_paused(false)

func _on_menu_button_pressed():
	set_paused(false)
	GameManager.back_to_menu()
