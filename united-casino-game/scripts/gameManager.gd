extends Node
# Registered as the GameManager autoload in project settings, so every scene,
# script and dialogue file shares the same money/bet/loan state.
# Use it from anywhere with GameManager.player_money, GameManager.setBet(...), etc.

var shopResource = load("res://dialogue/shopDialogue/shop.dialogue")
var dialogueScene = load("res://scenes/balloon.tscn")

# scenes the game manager swaps between
var casinoScene = load("res://scenes/main.tscn")
var shopScene = load("res://scenes/shop.tscn")
var gameOverScene = load("res://scenes/game_over.tscn")

# the casino waits here (out of the tree) while the shop is open,
# so the player comes back to the same spot
var saved_scene = null
# set when the player says yes to Mr. Shady, the shop opens once that dialogue is over
var shop_wanted = false
var is_game_over = false

# chance (0 to 1) that a searching guard checks a hiding spot it walks past.
# buffs will be able to lower this later
var hiding_spot_check_chance = 0.5

# var player_money = 500
var player_money = 1001
# each round's goal is 1000 * 5^round: 1000, then 5000, then 25000, ...
# quotas_paid counts the rounds already paid, so round 1 is 5^0
const BASE_QUOTA = 1000
var quota_mult = 5
var quotas_paid = 0
var current_quota = BASE_QUOTA

# seconds you get to pay each round
const QUOTA_TIME = 300
var quota_timer = QUOTA_TIME
var current_bet = 0
var is_dialogue_running = false

# shop interaction variables
var firstBuy = true
var firstCards = true

enum Item {
	card = 100
}

var inventory = []

# can upgrade to 5 with the inventory space buff
var inventorySpace = 3

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

# sets bet
func setBet(bet):
	current_bet = bet

# returns false if the player couldn't cover the full amount (money hits 0)
func player_loseMoney(amount) -> bool:
	var could_pay = player_money - amount > 0
	player_money = max(player_money - amount, 0)
	
	print("Money: ", player_money)
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
	current_quota = BASE_QUOTA * quota_mult ** quotas_paid
	# new round, new clock
	quota_timer = QUOTA_TIME
	
	update_UI()
	pass

# only charges if the item fits in the inventory
func buyItem(item: Item):
	if !hasEnough(getCost(item)):
		return -1
	
	# add item to inventory
	if !add_to_inventory(item):
		return 0
	player_loseMoney(getCost(item))
	return 1

func hasInventorySpace():
	return len(inventory) < inventorySpace

func add_to_inventory(item):
	print("Inventory: ", inventory)
	if len(inventory) < inventorySpace:
		inventory.append(item)
		return true
	return false
	
# updates the UI
func update_UI():

	# tick down the quota timer
	pass

func _process(delta):
	# update the quota timer (delta is in seconds, so this counts down in real time)
	quota_timer = max(quota_timer - delta, 0)
	pass

func _on_dialogue_started(dialogue) -> void:
	is_dialogue_running = true

func _on_dialogue_ended(dialogue) -> void:
	is_dialogue_running = false
	if shop_wanted:
		shop_wanted = false
		open_shop()

# scene switching: the current scene is taken out of the tree and the next one is added.
# it happens at the end of the frame (call_deferred) so nothing is removed halfway through an update
func play():
	quota_timer = QUOTA_TIME
	call_deferred("switch_scene", casinoScene.instantiate(), false)

func open_shop():
	call_deferred("switch_scene", shopScene.instantiate(), true)

func close_shop():
	if saved_scene == null:
		return
	call_deferred("switch_scene", saved_scene, false)
	saved_scene = null

func game_over():
	if is_game_over:
		return
	is_game_over = true
	call_deferred("switch_scene", gameOverScene.instantiate(), false)

# keep_old saves the old scene to come back to, otherwise it gets deleted
func switch_scene(new_scene, keep_old):
	var old_scene = get_tree().current_scene
	get_tree().root.remove_child(old_scene)
	if keep_old:
		saved_scene = old_scene
	else:
		old_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
