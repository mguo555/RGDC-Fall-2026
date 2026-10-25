extends RefCounted
class_name Dealer

var dealer_hand = []
var stand_at = null # NULL BECAUSE IT STARTS RANDOM
var MAX_STAND_AT = 17
var MIN_STAND_AT = 16
var has_stood = false 
var bust = false

func _init():
	reset()
	
func reset():
	dealer_hand = []
	has_stood = false
	bust = false
	stand_at = randi_range(MIN_STAND_AT, MAX_STAND_AT)

func get_hand():
	return dealer_hand

func busted():
	bust = true

# HITS IF THEYRE LOWER THAN THEIR STAND VALUE, AND THEY HAVENT STOOD
# YET AND THEY HAVENT BUSTED YET
func hit():
	var current_val = Card.summed_values(dealer_hand)
	if current_val < stand_at && not has_stood && not bust:
		return true
	else:
		has_stood = true
		return false
