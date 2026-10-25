extends Node
const card_scene = preload("res://scenes/card.tscn")
const CARD_HEIGHT = 740 # KEEPS THE CARDS ABOVE THE DIALOGUE BOX
const PLAYER_CARD_START = 200
const CARD_STEP = 128
const DEALER_CARD_START = 1700
const DECK_X = 960
const CARD_SIZE = Vector2(168, 240) # A 56x80 CARD AT 3X
const POPUP_SPOT = Vector2(170, 490) # JUST ABOVE YOUR HAND TOTAL
const SLIDE_TIME = 0.3 # HOW LONG A SWAPPED CARD TAKES TO SLIDE INTO PLACE
var resource = load("res://dialogue/blackjack.dialogue")

# TIP THE DEALER. IT'S A BRIBE, SO ONLY TIP WHEN NOBODY'S WATCHING OR YOU GET KICKED OUT
# THE TIP IS PAID UP FRONT AND THE DEALER KEEPS IT, WIN OR LOSE. IT CAN'T BE MORE THAN YOUR BET
# FAVOR = TIP / BET. WHEN YOU WIN, THE DEALER HELPS WITH A CHANCE OF FAVOR
# AND SLIPS YOU AN EXTRA BET * (1 + TIP_BONUS * FAVOR)
#   TIP 25% OF BET: 25% CHANCE OF +1.5X BET, LOSES MORE THAN NOT TIPPING
#   TIP 75% OF BET: 75% CHANCE OF +2.5X BET, ABOUT EVEN
#   TIP 100% OF BET: ALWAYS +3X BET ON A WIN, BEATS THE HOUSE (ABOUT +0.2 BETS A ROUND)
const TIP_BONUS = 2


var dealer = null # STARTS NULL AS IS INSTANTIATED IN READY
var card_list = [] # STARTS EMPTY, STARTS WITH A STANDARD DECK OF 52 CARDS
var discard_list = [] # CARDS THAT HAVE BEEN DRAWN, SHUFFLED BACK IN WHEN THE DECK RUNS OUT
var player_hand = [] # STARTS EMPTY, IS DEALT CARDS IN START_GAME
var next_card # EXISTS TO IMPLEMENT A CHEAT TO KNOW THE NEXT CARD
var round_over = true # MAKES SURE EACH ROUND IS ONLY PAID OUT ONCE
var player_won = false
var playing = false # TRUE WHILE THE BLACKJACK DIALOGUE IS OPEN
var tip = 0
var dealer_helped = false # TRUE WHEN THE DEALER SLIPPED YOU EXTRA THIS ROUND
var kicked_out = false # TRUE ONCE YOU'VE BEEN CAUGHT CHEATING
var is_push = false # TRUE WHEN THE ROUND WAS A TIE
var prompt_center_box
var player_amount_label
var dealer_amount_label
var card_container
var leave_button
var security_camera
var passersby
var hud
var camera_label
var dealer_sprite
var dealer_y # WHERE THE DEALER SITS, HE BOBS AROUND THIS
var bob_time = 0.0
var bet_field
var tip_field

const SUITS = ["Clubs", "Spades", "Diamonds", "Hearts"] # USED TO INITIALIZE ALL THE SUITS

func _ready():
	shuffle()
	prompt_center_box = $PromptCenterBox
	player_amount_label = $PlayerAmount
	dealer_amount_label = $DealerAmount
	card_container = $CardContainer
	leave_button = $LeaveButton
	security_camera = $SecurityCamera
	passersby = $Passersby
	hud = $HUD
	camera_label = $CameraLabel
	dealer_sprite = $DealerSprite
	dealer_y = dealer_sprite.position.y
	bet_field = $"PromptCenterBox/PromptPanel/PromptVertical Allignment/BetRow/BetField"
	tip_field = $"PromptCenterBox/PromptPanel/PromptVertical Allignment/TipRow/TipField"
	dealer = Dealer.new()
	var deck_card = card_scene.instantiate()
	deck_card.setup("Deck Backs", 1)
	add_child(deck_card)
	move_child(deck_card, card_container.get_index())
	deck_card.change_sprite(DECK_X, CARD_HEIGHT)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

# CARDS THAT AREN'T ON THE TABLE AREN'T CHILDREN, SO THEY HAVE TO BE FREED BY HAND
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for card in card_list + discard_list:
			if is_instance_valid(card) and card.get_parent() == null:
				card.free()

# CLEARS THE LIST, AND REINITALIZES ALL THE CARDS WITH A STANDARD DECK OF CARDS
func shuffle():
	card_list = []
	discard_list = []
	for suit in SUITS:
		for i in range(2, 11, 1):
			var new_card = card_scene.instantiate()
			new_card.setup(suit, i)
			card_list.append(new_card)
		var new_card = card_scene.instantiate()
		new_card.setup(suit, "Jack")
		card_list.append(new_card)
		new_card = card_scene.instantiate()
		new_card.setup(suit, "Queen")
		card_list.append(new_card)
		new_card = card_scene.instantiate()
		new_card.setup(suit, "King")
		card_list.append(new_card)
		new_card = card_scene.instantiate()
		new_card.setup(suit, "Ace")
		card_list.append(new_card)
	draw_next_card()

# TAKES THE NEXT CARD OUT OF THE DECK. IF THE DECK IS EMPTY, EVERY CARD THAT
# ISN'T ON THE TABLE GETS SHUFFLED BACK IN FIRST
func draw_next_card():
	if card_list.is_empty():
		for card in discard_list.duplicate():
			if card.get_parent() == null:
				discard_list.erase(card)
				card_list.append(card)
	next_card = card_list.pick_random()
	card_list.erase(next_card) #REMOVES next card from the list of possible next cards
	discard_list.append(next_card)

# FUNCTION USED TO ADD A CARD TO A HAND, AND REASSIGN THE NEXT CARD
func deal_card(hand, card_x, below = false):
	hand.append(next_card)
	print(next_card)
	card_container.add_child(next_card)
	if below:
		card_container.move_child(next_card, 0)
	next_card.change_sprite(card_x, CARD_HEIGHT)
	draw_next_card()

# FUCNTION CALLED TO START A GAME, FIRST EMPTIES THE PLAYER'S AND DEALERS HANDS
# THEN DEALS BOTH 2 CARDS TO EACH

func update_label_amounts():
	dealer_amount_label.text = str(Card.summed_values(dealer.get_hand()))
	player_amount_label.text = str(Card.summed_values(player_hand))

func start_game():
	kill_cards()
	round_over = false
	player_won = false
	is_push = false
	dealer_helped = false
	deal_card(player_hand, PLAYER_CARD_START)
	deal_card(player_hand, PLAYER_CARD_START + CARD_STEP)
	#print("PLAYER", player_hand) # TEST CODE
	deal_card(dealer.get_hand(), DEALER_CARD_START, true)
	deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP, true)
	#print("DEALER:", dealer.get_hand()) # TEST CODE
	update_label_amounts()
	# BEING DEALT 21 ENDS THE ROUND RIGHT AWAY: A WIN, OR A PUSH IF THE DEALER HAS 21 TOO
	if Card.summed_values(player_hand) == 21:
		if Card.summed_values(dealer.get_hand()) == 21:
			push()
		else:
			win()

# THE FUNCTION CALLED WHEN THE PLAYER WANTS TO HIT
func hit():
	deal_card(player_hand, PLAYER_CARD_START + CARD_STEP * len(player_hand))
	#print("PLAYER:", player_hand) # TEST
	update_label_amounts()
	if Card.bust(player_hand):
		bust()
	elif Card.summed_values(player_hand) == 21:
		# 21 CAN'T BE BEATEN, SO YOU STAND AUTOMATICALLY
		stand()

# CHECKS FOR PLAYER BUST STATUS
func has_player_busted():
	return Card.bust(player_hand)
# CONSEQUENCES OF BUSTING, LOSING MONEY
func bust():
	end_round(false)
# CONSEQUENCES OF WINNING, GAINING MONEY
func win():
	end_round(true)

# A TIE: NOBODY WINS AND YOU KEEP YOUR BET
func push():
	if round_over:
		return
	round_over = true
	player_won = false
	is_push = true
	show_money_popup(0)

# PAYS OUT THE BET THROUGH THE GAME MANAGER, ONLY ONCE PER ROUND
func end_round(won):
	if round_over:
		return
	round_over = true
	player_won = won
	var money_before = GameManager.player_money
	if won:
		GameManager.player_winBet()
		# A TIP BUYS A CHANCE THAT THE DEALER SLIPS YOU EXTRA ON A WIN
		if tip > 0 and randf() < favor():
			dealer_helped = true
			GameManager.player_winMoney(int(GameManager.current_bet * (1 + TIP_BONUS * favor())))
	else:
		GameManager.player_loseBet()
	print("ROUND OVER, PLAYER WON: ", won, " MONEY: ", GameManager.player_money)
	show_money_popup(GameManager.player_money - money_before)

# SHOWS +$X OR -$X ABOVE YOUR HAND THAT FLOATS UP AND FADES OUT
func show_money_popup(amount):
	var popup = Label.new()
	if amount > 0:
		popup.text = "+$%d" % amount
		popup.add_theme_color_override("font_color", Color(0.4, 1, 0.4))
	elif amount < 0:
		popup.text = "-$%d" % -amount
		popup.add_theme_color_override("font_color", Color(1, 0.35, 0.35))
	else:
		popup.text = "Push"
	popup.add_theme_font_size_override("font_size", 64)
	popup.add_theme_color_override("font_outline_color", Color.BLACK)
	popup.add_theme_constant_override("outline_size", 12)
	popup.position = POPUP_SPOT
	add_child(popup)
	var tween = create_tween()
	tween.tween_property(popup, "position:y", POPUP_SPOT.y - 80, 1.2)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 1.2)
	tween.tween_callback(popup.queue_free)

# THE DEALER ONLY PLAYS ONCE YOU STAND, AND HITS UNTIL THEY REACH THEIR STAND VALUE
func stand():
	while dealer.hit():
		deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP * len(dealer.get_hand()), true)
		update_label_amounts()
		#print("DEALER:", dealer.get_hand()) # TEST
	if Card.bust(dealer.get_hand()):
		dealer.busted()
	# SAME TOTAL AND NOBODY BUSTED IS A PUSH
	if not dealer.bust and Card.summed_values(player_hand) == Card.summed_values(dealer.get_hand()):
		push()
	else:
		end_round(who_wins_after_standing())

# PLAYER WINS IF THE DEALER BUSTS, OR IF THEY DIDNT BUST AND BEAT THE
# DEALER'S VALUE (TIES ARE A PUSH, SEE STAND)
func who_wins_after_standing():
	var player_sum = Card.summed_values(player_hand)
	var dealer_sum = Card.summed_values(dealer.get_hand())
	# A BUSTED HAND ALWAYS LOSES, EVEN IF THE DEALER BUSTS TOO
	if player_sum <= 21 and (player_sum > dealer_sum or dealer.bust):
		return true
	else:
		return false

func kill_cards():
	for card in player_hand:
		card_container.remove_child(card)
		# CARDS SWAPPED IN FROM YOUR INVENTORY AREN'T PART OF THE DECK, SO THEY GET THROWN OUT
		if not card in discard_list:
			card.queue_free()
	for card in dealer.get_hand():
		card_container.remove_child(card)
	player_hand.clear()
	dealer.reset()

func hide_labels():
	player_amount_label.hide()
	dealer_amount_label.hide()

func ask_bet():
	prompt_center_box.show()
	kill_cards()
	hide_labels()

func show_labels():
	player_amount_label.show()
	dealer_amount_label.show()


func has_player_won():
	return round_over and player_won

# USED BY THE DIALOGUE TO ONLY OFFER "PLAY AGAIN" IF THE PLAYER CAN COVER THE BET
func can_afford_bet():
	return GameManager.current_bet <= GameManager.player_money


# HOW MUCH THE DEALER LIKES YOU THIS ROUND, FROM 0 TO 1
func favor():
	return min(float(tip) / GameManager.current_bet, 1.0)

func _on_deal_button_pressed():
	_on_bet_field_text_submitted("")

# PRESSING DEAL (OR ENTER IN THE BET OR TIP BOX) STARTS THE ROUND
func _on_bet_field_text_submitted(_new_text: String) -> void:
	# IGNORE NEW BETS WHILE A ROUND IS STILL BEING PLAYED
	if playing:
		return
	var bet = int(bet_field.text)
	var new_tip = int(tip_field.text)
	if bet <= 0 or new_tip > bet or bet + new_tip > GameManager.player_money:
		print("CAN'T BET ", bet, " AND TIP ", new_tip, ", YOU HAVE ", GameManager.player_money)
		return
	if new_tip > 0 and is_being_watched():
		caught_cheating()
		return
	GameManager.setBet(bet)
	tip = new_tip
	if tip > 0:
		GameManager.player_loseMoney(tip)
		GameManager.add_heat()
	playing = true
	prompt_center_box.hide()
	show_labels()
	start_game()
	DialogueManager.show_dialogue_balloon_scene("res://scenes/balloon.tscn",resource, "start", [self])

func _process(delta):
	# THE DEALER BOBS A LITTLE SO THE TABLE FEELS ALIVE
	bob_time += delta
	dealer_sprite.position.y = dealer_y + sin(bob_time * 2.5) * 6
	# NO LEAVING IN THE MIDDLE OF A ROUND
	leave_button.disabled = playing
	# COUNTDOWN WHILE AN EMF HAS THE CAMERA KNOCKED OUT
	camera_label.visible = security_camera.off_timer > 0
	camera_label.text = "Camera off: %ds" % ceil(security_camera.off_timer)

# YOU CAN ONLY CHEAT WHILE THE CAMERA LOOKS AWAY AND NO GUARD IS LOOKING AT YOUR TABLE
func is_being_watched():
	return security_camera.is_looking() or passersby.anyone_watching()

func can_cheat():
	return not is_being_watched()

# CHEATING IN FRONT OF SOMEONE GETS YOU THROWN BACK ONTO THE FLOOR WITH SECURITY ON YOUR TAIL
func caught_cheating():
	if kicked_out:
		return
	print("CAUGHT CHEATING")
	kicked_out = true
	# CUT OFF WHATEVER THE DEALER WAS SAYING
	for child in get_children():
		if child.get_script() and child.get_script().resource_path == "res://scripts/balloon.gd":
			child.queue_free()
	DialogueManager.show_dialogue_balloon_scene("res://scenes/balloon.tscn", resource, "caught", [self])

# YOU CAN ONLY SWAP CARDS DURING YOUR TURN
func can_swap():
	return playing and not round_over

# WHICH CARD IN YOUR HAND IS UNDER THIS SPOT, -1 IF NONE (THE TOP CARD WINS WHERE THEY OVERLAP)
func hand_card_at(spot):
	for i in range(player_hand.size() - 1, -1, -1):
		var card = player_hand[i]
		if Rect2(card.position - CARD_SIZE / 2, CARD_SIZE).has_point(spot):
			return i
	return -1

# SLEIGHT OF HAND: PUTS A CARD FROM YOUR INVENTORY INTO YOUR HAND IN PLACE OF ANOTHER ONE.
# THE NEW CARD SLIDES IN FROM WHERE YOU DROPPED IT AND THE OLD ONE SLIDES OFF THE TABLE
func swap_card(hand_index, inventory_card, from_position):
	var old_card = player_hand[hand_index]
	var slot = old_card.position
	var new_card = card_scene.instantiate()
	new_card.setup(inventory_card.suit, inventory_card.value)
	card_container.add_child(new_card)
	card_container.move_child(new_card, old_card.get_index())
	new_card.change_sprite(from_position.x, from_position.y)
	player_hand[hand_index] = new_card
	update_label_amounts()
	GameManager.add_heat()
	# THE OLD CARD SLIDES OUT FROM BEHIND THE OTHERS
	card_container.move_child(old_card, 0)
	var tween = create_tween()
	tween.tween_property(new_card, "position", slot, SLIDE_TIME)
	tween.parallel().tween_property(old_card, "position", slot + Vector2(0, 400), SLIDE_TIME)
	tween.tween_callback(card_container.remove_child.bind(old_card))

# CLICKING AN EMF IN YOUR INVENTORY KNOCKS OUT THE CAMERA
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var index = hud.inventory_item_at(event.position)
		if index != -1 and GameManager.inventory[index] is int and GameManager.inventory[index] == GameManager.Item.emf:
			get_viewport().set_input_as_handled()
			GameManager.inventory.remove_at(index)
			security_camera.knock_out()

# GOES BACK TO THE CASINO
func _on_leave_button_pressed():
	GameManager.close_scene()

func _on_dialogue_ended(ended_resource):
	if ended_resource == resource:
		playing = false
		if kicked_out:
			GameManager.caught_cheating()
