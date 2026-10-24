extends RefCounted
class_name Dealer

var dealer_hand = []
var stand_at = null
var MAX_STAND_AT = 21
var MIN_STAND_AT = 16
var has_stood = false

func _ready():
	reset()
	
func reset():
	dealer_hand.clear()
	has_stood = false
	stand_at = randi_range(MIN_STAND_AT, MAX_STAND_AT)

func get_hand():
	return dealer_hand

func hit():
	var current_val = Card.summed_values(dealer_hand)
	if current_val < stand_at && not has_stood:
		return true
	else:
		has_stood = true
		return false
