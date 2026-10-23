extends Node

var card_list = [] 
var player_hand = []
const SUITS = ["C", "S", "D", "H"]

class Card:
	var suit: String
	var value
	
	func _init(p_suit: String, p_value) -> void:
		suit = p_suit
		value = p_value

func shuffle():
	card_list.clear()
	for suit in SUITS:
		for i in range(1, 11, 1):
			card_list.append(Card.new(suit, i))
		card_list.append(Card.new(suit, "J"))
		card_list.append(Card.new(suit, "Q"))
		card_list.append(Card.new(suit, "K"))
		card_list.append(Card.new(suit, "A"))
