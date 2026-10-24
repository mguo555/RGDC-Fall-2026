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
