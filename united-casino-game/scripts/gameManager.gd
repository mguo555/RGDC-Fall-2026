extends Node2D
var shopResource = load("res://dialogue/shopDialogue/shop.dialogue")
var dialogueScene = load("res://scenes/balloon.tscn")

static var player_money = 500
static var current_quota = 1000
static var quota_mult = 5
static var quotas_paid = 0

# in seconds
static var quota_timer = 300
static var current_bet = 0

# sets bet
static func setBet(bet):
	current_bet = bet

static func player_loseMoney(amount) -> bool:
	if (player_money - amount) <= 0:
		return false
	player_money -= amount
	update_UI()
	return true

static func player_winMoney(amount):
	player_money += amount
	update_UI()

static func player_winBet():
	player_winMoney(current_bet)

static func player_loseBet():
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
	
	# show your stats (total money made,
	pass

func hasEnough(cost):
	return (player_money - cost) > 0

func payLoan():
	player_money -= current_quota
	quotas_paid += 1
	current_quota *= quota_mult
	
	update_UI()
	pass

# updates the UI
static func update_UI():
	
	# tick down the quota timer
	pass

func _process(delta):
	# update the quota timer
	quota_timer -= 1
	pass
	
	
