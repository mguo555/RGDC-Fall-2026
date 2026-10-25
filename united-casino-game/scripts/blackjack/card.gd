extends Node2D
class_name Card

# letter_vals exists to turn the face cards + ace into numbers
const letter_vals = {"King" : 10, "Queen" : 10, "Jack" : 10, "Ace" : Vector2i(1, 11)}
var suit: String
var value # either string or int
@onready var sprite = $Cardsprite


func setup(p_suit: String, p_value) -> void:
	suit = p_suit
	value = p_value
	

func change_sprite(sprite_x, sprite_y):
	var card_num = 0
	sprite.animation = suit
	if value is String:
		match value:
			"Jack":
				card_num = 10
			"Queen":
				card_num = 11
			"King":
				card_num = 12
			"Ace":
				card_num = 0
	else:
		card_num = value - 1
	sprite.frame = card_num
	position = Vector2i(sprite_x, sprite_y)

func get_value():
	if value is String:
		return letter_vals[value] # the dictionary turns the face cards + ace to int
	else:
		return value

# static as it should just handle cards not be called by a card
# it adds up all the cards in a list and returns the total value
# with ace being 11 if it can fit, otherwise 1
static func summed_values(card_list):
	var total_value = 0
	var aces = 0
	for card in card_list:
		var temp_val = card.get_value()
		if temp_val is Vector2i:
			aces += 1
			total_value += 1
		else:
			total_value += temp_val
	# ONLY ONE ACE CAN EVER COUNT AS 11 (TWO WOULD ALREADY BE 22)
	if aces > 0 and total_value + 10 < 22:
		total_value += 10
	return total_value

# just checking if summed values is a bust
static func bust(card_list):
	if summed_values(card_list) > 21:
		return true
	return false

func _to_string() -> String:
	return "Card(Suit: %s, Val: %s)" % [suit, value]
