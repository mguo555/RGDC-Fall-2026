extends Node
const player_bank = preload("res://scripts/player_bank.gd")
var resource = load("res://dialogue/blackjack.dialogue")


var dealer = null
var card_list = [] 
var player_hand = []
var next_card = null
var player_bet = 0 # TODO FIGURE OUT HOW TO DEAL WITH BETS

const SUITS = ["Clubs", "Spades", "Diamonds", "Hearts"]

func _ready():
	shuffle()
	next_card = card_list.pick_random()
	dealer = Dealer.new()
	start_game()
	DialogueManager.show_dialogue_balloon(resource, "start", [self])

func shuffle():
	card_list.clear()
	for suit in SUITS:
		for i in range(1, 11, 1):
			card_list.append(Card.new(suit, i))
		card_list.append(Card.new(suit, "Jack"))
		card_list.append(Card.new(suit, "Queen"))
		card_list.append(Card.new(suit, "King"))
		card_list.append(Card.new(suit, "Ace"))

func deal_card(hand):
	hand.append(next_card)
	next_card = card_list.pick_random()
	card_list.erase(next_card)

func start_game():
	player_hand.clear()
	dealer.reset()
	deal_card(player_hand)
	deal_card(player_hand)
	print("PLAYER", player_hand)
	deal_card(dealer.get_hand())
	deal_card(dealer.get_hand())
	print("DEALER:", dealer.get_hand())


func hit():
	deal_card(player_hand)
	print("PLAYER:", player_hand)
	if Card.bust(player_hand):
		bust()
	if dealer.hit():
		deal_card(dealer.get_hand())
		print("DEALER:", dealer.get_hand())
		if Card.bust(dealer.get_hand()):
			win()

func has_player_busted():
	return Card.bust(player_hand)

func bust():
	player_bank.pay(player_bet)

func win():
	player_bank.add(player_bet)

func stand():
	while dealer.hit():
		deal_card(dealer.get_hand())
		print("DEALER:", dealer.get_hand())

func has_player_won():
	var player_sum = Card.summed_values(player_hand)
	var dealer_sum = Card.summed_values(dealer.get_hand())
	if dealer_sum > player_sum && not dealer.busted:
		bust()
		return false
	else:
		win()
		return true
