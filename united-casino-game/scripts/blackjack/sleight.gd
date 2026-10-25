extends Node2D

# SLEIGHT OF HAND: DURING YOUR TURN, DRAG A CARD FROM YOUR INVENTORY ONTO A CARD IN YOUR HAND TO SWAP IT IN.
# IT'S CHEATING, SO IF THE CAMERA OR ANYONE WALKING BY SEES YOU WHILE YOU HOLD THE CARD,
# OR YOU TAKE LONGER THAN SLEIGHT_TIME, YOU GET CAUGHT
const SLEIGHT_TIME = 2.0
const card_scene = preload("res://scenes/card.tscn")

@onready var blackjack = get_parent()
var held_card = null # THE CARD FOLLOWING THE MOUSE
var held_index = -1 # WHICH INVENTORY SLOT IT CAME FROM
var held_time = 0.0


# _input INSTEAD OF _unhandled_input SO CLICKS ON THE HUD REACH US
func _input(event):
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if event.pressed and held_card == null and blackjack.can_swap():
		var index = blackjack.hud.inventory_item_at(event.position)
		if index != -1 and GameManager.inventory[index] is Dictionary:
			get_viewport().set_input_as_handled()
			pick_up(index)
	elif not event.pressed and held_card != null:
		get_viewport().set_input_as_handled()
		drop(event.position)


func _process(delta):
	if held_card == null:
		return
	held_card.position = get_global_mouse_position()
	held_time += delta
	# THE CARD TURNS RED AS YOU RUN OUT OF TIME
	held_card.modulate = Color.WHITE.lerp(Color.RED, held_time / SLEIGHT_TIME)
	if blackjack.is_being_watched() or held_time > SLEIGHT_TIME:
		let_go()
		blackjack.caught_cheating()


func pick_up(index):
	var card = GameManager.inventory[index]
	held_index = index
	held_time = 0.0
	held_card = card_scene.instantiate()
	held_card.setup(card.suit, card.value)
	add_child(held_card)
	held_card.change_sprite(get_global_mouse_position().x, get_global_mouse_position().y)


# DROPPING IT ON ONE OF YOUR CARDS SWAPS THEM, DROPPING IT ANYWHERE ELSE PUTS IT BACK
func drop(drop_position):
	var hand_index = blackjack.hand_card_at(drop_position)
	if hand_index != -1:
		blackjack.swap_card(hand_index, GameManager.inventory[held_index], drop_position)
		GameManager.inventory.remove_at(held_index)
	let_go()


func let_go():
	held_card.queue_free()
	held_card = null
