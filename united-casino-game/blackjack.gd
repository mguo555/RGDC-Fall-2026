extends Node

var dealer = null
var card_list = [] 
var player_hand = []
var next_card = null
const SUITS = ["C", "S", "D", "H"]

func _ready():
	shuffle()
	next_card = card_list.pick_random()
	dealer = Dealer.new()

func shuffle():
	card_list.clear()
	for suit in SUITS:
		for i in range(1, 11, 1):
			card_list.append(Card.new(suit, i))
		card_list.append(Card.new(suit, "J"))
		card_list.append(Card.new(suit, "Q"))
		card_list.append(Card.new(suit, "K"))
		card_list.append(Card.new(suit, "A"))

func deal_card(hand):
	hand.append(next_card)
	next_card = card_list.pick_random()
	card_list.remove(next_card)

func start_game():
	player_hand.clear()
	dealer.reset()
	deal_card(player_hand)
	deal_card(player_hand)
	deal_card(dealer.get_hand())
	deal_card(dealer.get_hand())

func hit():
	deal_card(player_hand)
	# TODO indicator of busting
	if dealer.hit():
		deal_card(dealer.get_hand())

func stand():
	while dealer.hit():
		deal_card(dealer.get_hand())
