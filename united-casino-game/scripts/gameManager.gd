extends Node
# Registered as the GameManager autoload in project settings, so every scene,
# script and dialogue file shares the same money/bet/loan state.
# Use it from anywhere with GameManager.player_money, GameManager.setBet(...), etc.

var shopResource = load("res://dialogue/shopDialogue/shop.dialogue")
var dialogueScene = load("res://scenes/balloon.tscn")
# @onready var playerStats = $CanvasLayer/CenterContainer/VBoxContainer/PlayerStats
signal updatedUI

# var player_money = 500
var player_money = 1001
var current_quota = 1000
var quota_mult = 5
var quotas_paid = 0

# in seconds
var quota_timer = 300
var current_bet = 0
var is_dialogue_running = false

# shop interaction variables
# TODO: Change  them
var firstBuy = false
var firstCards = false
#var firstBuy = true
#var firstCards = true

enum Item {
	card = 100
}

var inventory = []

# can upgrade to 5 with the inventory space buff
var inventorySpace = 3

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	updatedUI.emit()
	
# sets bet
func setBet(bet):
	current_bet = bet

# returns false if the player couldn't cover the full amount (money hits 0)
func player_loseMoney(amount) -> bool:
	var could_pay = player_money - amount > 0
	player_money = max(player_money - amount, 0)
	update_UI()
	return could_pay

func player_winMoney(amount):
	player_money += amount
	update_UI()

func player_winBet():
	player_winMoney(current_bet)

func player_loseBet():
	player_loseMoney(current_bet)

# called when the timer runs out
func loanTimeUp():
	# play animation

	# call the dialogue
	DialogueManager.show_dialogue_balloon_scene(dialogueScene, shopResource, "payLoan", [self])
	pass

# couldn't pay your debts on time / money reaches 0
func lose():
	DialogueManager.show_dialogue_balloon_scene(dialogueScene, shopResource, "lose", [self])

	# show your stats (total money made, total quotas paid, # times caught, etc.)
	pass



func hasEnough(cost):
	return (player_money - cost) > 0

func getCost(cost):
	return cost * (quotas_paid + 1)

func payLoan():
	player_money -= current_quota
	quotas_paid += 1
	current_quota *= quota_mult
	
	update_UI()
	pass

func buyItem(item: Item):
	if !player_loseMoney(getCost(item)):
		return -1
	
	# add item to inventory
	if !add_to_inventory(item):
		return 0
	update_UI()
	return 1

func add_to_inventory(item):
	print("Inventory: ", inventory)
	if len(inventory) < inventorySpace:
		inventory.append(item)
		return true
	return false
	
# updates the UI
func update_UI():
	print("Emitting signal")
	print("GameManager: ", player_money)
	updatedUI.emit()
	# tick down the quota timer

func _process(delta):
	# update the quota timer (delta is in seconds, so this counts down in real time)
	quota_timer = max(quota_timer - delta, 0)

func _on_dialogue_started(dialogue) -> void:
	is_dialogue_running = true

func _on_dialogue_ended(dialogue) -> void:
	is_dialogue_running = false
	
