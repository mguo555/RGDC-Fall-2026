extends Node
const player_bank = preload("res://scripts/player_bank.gd")
var resource = load("res://dialogue/blackjack.dialogue")


var dealer = null # STARTS NULL AS IS INSTANTIATED IN READY
var card_list = [] # STARTS EMPTY, STARTS WITH A STANDARD DECK OF 52 CARDS
var player_hand = [] # STARTS EMPTY, IS DEALT CARDS IN START_GAME
var next_card = null # EXISTS TO IMPLEMENT A CHEAT TO KNOW THE NEXT CARD
var player_bet = 0 # TODO FIGURE OUT HOW TO DEAL WITH BETS

const SUITS = ["Clubs", "Spades", "Diamonds", "Hearts"] # USED TO INITIALIZE ALL THE SUITS

func _ready():
	shuffle() 
	next_card = card_list.pick_random()
	dealer = Dealer.new()
	start_game()
	DialogueManager.show_dialogue_balloon(resource, "start", [self])

# CLEARS THE LIST, AND REINITALIZES ALL THE CARDS WITH A STANDARD DECK OF CARDS
func shuffle():
	card_list.clear()
	for suit in SUITS:
		for i in range(1, 11, 1):
			card_list.append(Card.new(suit, i))
		card_list.append(Card.new(suit, "Jack"))
		card_list.append(Card.new(suit, "Queen"))
		card_list.append(Card.new(suit, "King"))
		card_list.append(Card.new(suit, "Ace"))

# FUNCTION USED TO ADD A CARD TO A HAND, AND REASSIGN THE NEXT CARD
func deal_card(hand):
	hand.append(next_card)
	next_card = card_list.pick_random() 
	card_list.erase(next_card) #REMOVES next card from the list of possible next cards

# FUCNTION CALLED TO START A GAME, FIRST EMPTIES THE PLAYER'S AND DEALERS HANDS
# THEN DEALS BOTH 2 CARDS TO EACH
func start_game():
	player_hand.clear()
	dealer.reset()
	deal_card(player_hand)
	deal_card(player_hand)
	print("PLAYER", player_hand) # TEST CODE
	deal_card(dealer.get_hand())
	deal_card(dealer.get_hand())
	print("DEALER:", dealer.get_hand()) # TEST CODE

# THE FUNCTION CALLED WHEN THE PLAYER WANTS TO HIT
func hit():
	deal_card(player_hand)
	print("PLAYER:", player_hand) # TEST
	if Card.bust(player_hand):
		bust()
	else:
		# IF THE PLAYER HASNT BUSTED THE DEALERS TURN OCCURS
		if dealer.hit():
			deal_card(dealer.get_hand())
			print("DEALER:", dealer.get_hand()) # TEST
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
		deal_card(dealer.get_hand())
		print("DEALER:", dealer.get_hand()) # TEST

# PLAYER WINS ONLY IF THEY HAVE A LARGER VAL THAN DEALER AND DIDNT BUST. DEALER WINS
# IF BOTH BUST.
func has_player_won():
	var player_sum = Card.summed_values(player_hand)
	var dealer_sum = Card.summed_values(dealer.get_hand())
	if (dealer_sum > player_sum && not dealer.busted) or has_player_busted():
		bust()
		return false
	else:
		win()
		return true
