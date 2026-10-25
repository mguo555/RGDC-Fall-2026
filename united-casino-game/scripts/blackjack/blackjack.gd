extends Node
const card_scene = preload("res://scenes/card.tscn")
const CARD_HEIGHT = 800
const PLAYER_CARD_START = 200
const CARD_STEP = 128
const DEALER_CARD_START = 1700
const DECK_X = 960
var resource = load("res://dialogue/blackjack.dialogue")


var dealer = null # STARTS NULL AS IS INSTANTIATED IN READY
var card_list = [] # STARTS EMPTY, STARTS WITH A STANDARD DECK OF 52 CARDS
var discard_list = [] # CARDS THAT HAVE BEEN DRAWN, SHUFFLED BACK IN WHEN THE DECK RUNS OUT
var player_hand = [] # STARTS EMPTY, IS DEALT CARDS IN START_GAME
var next_card # EXISTS TO IMPLEMENT A CHEAT TO KNOW THE NEXT CARD
var round_over = true # MAKES SURE EACH ROUND IS ONLY PAID OUT ONCE
var player_won = false
var playing = false # TRUE WHILE THE BLACKJACK DIALOGUE IS OPEN
var prompt_center_box
var player_amount_label
var dealer_amount_label
var card_container

const SUITS = ["Clubs", "Spades", "Diamonds", "Hearts"] # USED TO INITIALIZE ALL THE SUITS

func _ready():
	shuffle()
	prompt_center_box = $PromptCenterBox
	player_amount_label = $PlayerAmount
	dealer_amount_label = $DealerAmount
	card_container = $CardContainer
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
	deal_card(player_hand, PLAYER_CARD_START)
	deal_card(player_hand, PLAYER_CARD_START + CARD_STEP)
	#print("PLAYER", player_hand) # TEST CODE
	deal_card(dealer.get_hand(), DEALER_CARD_START, true)
	deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP, true)
	#print("DEALER:", dealer.get_hand()) # TEST CODE
	update_label_amounts()

# THE FUNCTION CALLED WHEN THE PLAYER WANTS TO HIT
func hit():
	deal_card(player_hand, PLAYER_CARD_START + CARD_STEP * len(player_hand))
	#print("PLAYER:", player_hand) # TEST
	update_label_amounts()
	if Card.bust(player_hand):
		bust()
	elif Card.summed_values(player_hand) == 21:
		# HITTING EXACTLY 21 IS AN INSTANT WIN
		win()
	else:
		# IF THE PLAYER HASNT BUSTED THE DEALERS TURN OCCURS
		if dealer.hit():
			deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP * len(dealer.get_hand()), true)
			#print("DEALER:", dealer.get_hand()) # TEST
			if Card.bust(dealer.get_hand()):
				# IF THE DEALER BUSTS PLAYER INSTA WINS
				dealer.busted()
				win()

# CHECKS FOR PLAYER BUST STATUS
func has_player_busted():
	return Card.bust(player_hand)
# CONSEQUENCES OF BUSTING, LOSING MONEY
func bust():
	end_round(false)
# CONSEQUENCES OF WINNING, GAINING MONEY
func win():
	end_round(true)

# PAYS OUT THE BET THROUGH THE GAME MANAGER, ONLY ONCE PER ROUND
func end_round(won):
	if round_over:
		return
	round_over = true
	player_won = won
	if won:
		GameManager.player_winBet()
	else:
		GameManager.player_loseBet()
	print("ROUND OVER, PLAYER WON: ", won, " MONEY: ", GameManager.player_money)

# THE DEALER HAS INFINITE TURNS ONCE YOU STAND AND CAN HIT AS LONG AS THEY LIKE
func stand():
	while dealer.hit():
		deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP * len(dealer.get_hand()), true)
		update_label_amounts()
		#print("DEALER:", dealer.get_hand()) # TEST
	if Card.bust(dealer.get_hand()):
		dealer.busted()
	end_round(who_wins_after_standing())

# PLAYER WINS IF THE DEALER BUSTS, OR IF THEY DIDNT BUST AND BEAT THE
# DEALER'S VALUE (TIES GO TO THE DEALER)
func who_wins_after_standing():
	var player_sum = Card.summed_values(player_hand)
	var dealer_sum = Card.summed_values(dealer.get_hand())
	if (player_sum > dealer_sum && player_sum <= 21) or dealer.bust:
		return true
	else:
		return false

func kill_cards():
	for card in player_hand:
		card_container.remove_child(card)
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


func _on_bet_field_text_submitted(new_text: String) -> void:
	# IGNORE NEW BETS WHILE A ROUND IS STILL BEING PLAYED
	if playing:
		return
	var bet = int(new_text)
	if bet <= 0 or bet > GameManager.player_money:
		print("CAN'T BET ", bet, ", YOU HAVE ", GameManager.player_money)
		return
	GameManager.setBet(bet)
	playing = true
	prompt_center_box.hide()
	show_labels()
	start_game()
	DialogueManager.show_dialogue_balloon_scene("res://scenes/balloon.tscn",resource, "start", [self])

func _on_dialogue_ended(ended_resource):
	if ended_resource == resource:
		playing = false
