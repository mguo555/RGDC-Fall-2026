extends RefCounted
class_name Card

const letter_vals = {"K" : 10, "Q" : 10, "J" : 10, "A" : Vector2i(1, 11)}
var suit: String
var value

func _init(p_suit: String, p_value) -> void:
	suit = p_suit
	value = p_value

func get_value():
	if value is String:
		return letter_vals[value]
	else:
		return value

static func summed_values(card_list):
	var total_value = 0
	for card in card_list:
		total_value += card.get_value()
	return total_value

static func bust(card_list):
	if summed_values(card_list) > 21:
		return true
	return false
