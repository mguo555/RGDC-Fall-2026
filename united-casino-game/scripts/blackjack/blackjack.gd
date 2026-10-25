extends Node
const player_bank = preload("res://scripts/Player/player_bank.gd")
const card_scene = preload("res://scenes/card.tscn")
const CARD_HEIGHT = 400
const PLAYER_CARD_START = 200
const CARD_STEP = 128
const DEALER_CARD_START = 1700
var resource = load("res://dialogue/blackjack.dialogue")


var dealer = null # STARTS NULL AS IS INSTANTIATED IN READY
var card_list = [] # STARTS EMPTY, STARTS WITH A STANDARD DECK OF 52 CARDS
var discard_list = []
var player_hand = [] # STARTS EMPTY, IS DEALT CARDS IN START_GAME
var next_card # EXISTS TO IMPLEMENT A CHEAT TO KNOW THE NEXT CARD
var player_bet = 0 # TODO FIGURE OUT HOW TO DEAL WITH BETS

const SUITS = ["Clubs", "Spades", "Diamonds", "Hearts"] # USED TO INITIALIZE ALL THE SUITS

func _ready():
	shuffle() 
	dealer = Dealer.new()
	

# CLEARS THE LIST, AND REINITALIZES ALL THE CARDS WITH A STANDARD DECK OF CARDS
func shuffle():
	card_list = []
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
	next_card = card_list.pick_random()

# FUNCTION USED TO ADD A CARD TO A HAND, AND REASSIGN THE NEXT CARD
func deal_card(hand, card_x, below = false):
	if next_card == null:
		card_list = discard_list.duplicate()
		next_card = card_list.pick_random()
		discard_list = []
		discard_list.append(next_card)
		card_list.erase(next_card)
		
	hand.append(next_card)
	print(next_card)
	add_child(next_card)
	if below:
		move_child(next_card, 0)
	next_card.change_sprite(card_x, CARD_HEIGHT)		
	next_card = card_list.pick_random() 
	discard_list.append(next_card)
	card_list.erase(next_card) #REMOVES next card from the list of possible next cards

# FUCNTION CALLED TO START A GAME, FIRST EMPTIES THE PLAYER'S AND DEALERS HANDS
# THEN DEALS BOTH 2 CARDS TO EACH
func start_game():
	kill_cards()
	deal_card(player_hand, PLAYER_CARD_START)
	deal_card(player_hand, PLAYER_CARD_START + CARD_STEP)
	#print("PLAYER", player_hand) # TEST CODE
	deal_card(dealer.get_hand(), DEALER_CARD_START, true)
	deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP, true)
	#print("DEALER:", dealer.get_hand()) # TEST CODE

# THE FUNCTION CALLED WHEN THE PLAYER WANTS TO HIT
func hit():
	deal_card(player_hand, PLAYER_CARD_START + CARD_STEP * len(player_hand))
	#print("PLAYER:", player_hand) # TEST
	if Card.bust(player_hand):
		bust()
	else:
		# IF THE PLAYER HASNT BUSTED THE DEALERS TURN OCCURS
		if dealer.hit():
			deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP * len(dealer.get_hand()), true)
			#print("DEALER:", dealer.get_hand()) # TEST
			if Card.bust(dealer.get_hand()):
				# IF THE DEALER BUSTS PLAYER INSTA WINS
				win()

# CHECKS FOR PLAYER BUST STATUS
func has_player_busted():
	return Card.bust(player_hand)
# CONSEQUENCES OF BUSTING, LOSING MONEY
func bust():
	player_bank.pay(player_bet)
# CONSEQUENCES OF WINNING, GAINING MONEY
func win():
	player_bank.add(player_bet)
# THE DEALER HAS INFINITE TURNS ONCE YOU STAND AND CAN HIT AS LONG AS THEY LIKE
func stand():
	while dealer.hit():
		deal_card(dealer.get_hand(), DEALER_CARD_START - CARD_STEP * len(dealer.get_hand()), true)
		#print("DEALER:", dealer.get_hand()) # TEST

# PLAYER WINS ONLY IF THEY HAVE A LARGER VAL THAN DEALER AND DIDNT BUST. DEALER WINS
# IF BOTH BUST.
func who_wins_after_standing():
	var player_sum = Card.summed_values(player_hand)
	var dealer_sum = Card.summed_values(dealer.get_hand())
	if (dealer_sum > player_sum && not dealer.bust) or has_player_busted():
		bust()
		return false
	else:
		win()
		return true

func kill_cards():
	for card in player_hand:
		remove_child(card)
	for card in dealer.get_hand():
		remove_child(card)
	player_hand.clear()
	dealer.reset()

func has_player_won():
	print("THE PLAYER HAS WON THIS STATEMENT IS: ", dealer.busted or Card.summed_values(player_hand) == 21)
	print("THE DAELER HAS BUSTED: ", dealer.bust)
	print("PLAYER'S HAND VAL:" , Card.summed_values(player_hand))
	return dealer.bust or Card.summed_values(player_hand) == 21


func _on_bet_field_text_submitted(new_text: String) -> void:
	start_game()
	DialogueManager.show_dialogue_balloon_scene("res://scenes/balloon.tscn",resource, "start", [self])
