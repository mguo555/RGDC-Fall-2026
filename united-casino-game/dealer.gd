extends RefCounted
class_name Dealer

var dealer_hand = []
var stand_at = null
var MAX_STAND_AT = 21
var MIN_STAND_AT = 16

func _ready():
	reset()
	
func reset():
	dealer_hand.clear()
	stand_at = randi_range(MIN_STAND_AT, MAX_STAND_AT)

func get_hand():
	return dealer_hand

func dealer_turn():
	pass
