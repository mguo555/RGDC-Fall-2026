extends Node
# Registered as the GameManager autoload in project settings, so every scene,
# script and dialogue file shares the same money/bet/loan state.
# Use it from anywhere with GameManager.player_money, GameManager.setBet(...), etc.

# music
var chaseMusic = load("res://assets/music/chase.mp3")
var normalMusic = load("res://assets/music/normal-background-music.mp3")
var shopMusic = load("res://assets/music/Crime Scene Bensound.mp3")

# sfx
var alarmSfx = load("res://assets/sfx/security_alarm.mp3")
var deathSfx = load("res://assets/sfx/death.mp3")
var noticedSfx = load("res://assets/sfx/noticed.mp3")
var transitionSfx = load("res://assets/sfx/transition.mp3")
var textSfx = load("res://assets/sfx/text-speaking.mp3")

var shopResource = load("res://dialogue/shopDialogue/shop.dialogue")
var dialogueScene = load("res://scenes/balloon.tscn")

# scenes the game manager swaps between
var casinoScene = load("res://scenes/main.tscn")
var shopScene = load("res://scenes/shop.tscn")
var gameOverScene = load("res://scenes/game_over.tscn")
var introScene = load("res://scenes/intro.tscn")
var winScene = load("res://scenes/win_screen.tscn")
var startScene = load("res://scenes/start_screen.tscn")

# remembers things between launches, for now just whether you've seen the intro
const SAVE_PATH = "user://save.cfg"

# the casino waits here (out of the tree) while the shop or a game is open,
# so the player comes back to the same spot
var saved_scene = null
# set when the player says yes to Mr. Shady, the shop opens once that dialogue is over
var shop_wanted = false
var is_game_over = false

# chance (0 to 1) that a searching guard checks a hiding spot it walks past.
# buffs will be able to lower this later
var hiding_spot_check_chance = 0.5

# after you get away with a cheat you're "hot" for a while,
# any guard that sees you while you're hot comes after you
const HEAT_TIME = 30.0
var heat = 0.0
# after you're thrown out of a table you get a couple of seconds to run before anyone can grab you
const HEAD_START = 2.0
var head_start = 0.0

# var player_money = 500
const STARTING_MONEY = 1001
var player_money = STARTING_MONEY
# each round's goal is 1000 * 5^round: 1000, then 5000, then 25000, ...
# quotas_paid counts the rounds already paid, so round 1 is 5^0
const BASE_QUOTA = 1000
# pay off this many antes to be free of Mr. Shady
const ANTES = 5
var has_won = false
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
	card = 100,
	emf = 150, # knocks the blackjack camera out for 30 seconds
}

# cards in here look like {"suit": "Hearts", "value": "Ace"} (see random_card)
var inventory = []

# can upgrade to 5 with the inventory space buff
const STARTING_INVENTORY_SPACE = 3
var inventorySpace = STARTING_INVENTORY_SPACE

# buffs you have, the HUD lists whatever is in here
# TODO: buffs aren't designed yet, paying off a round should give one (see payLoan)
var buffs = []

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

# sets bet
func setBet(bet):
	current_bet = bet

# TODO: decide what happens when the player hits $0. right now they just can't bet anymore,
# so they can't make money or pay the quota (game over? an emergency loan? selling cards back?)
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
	# TODO (Matthew): paying an ante should give you a buff (the shop's ~ buff menu)
	
	update_UI()
	pass

# only charges if the item fits in the inventory
func buyItem(item: Item):
	if !hasEnough(getCost(item)):
		return -1
	
	# add item to inventory, a card comes out random
	# TODO (Matthew): maybe let the player see or pick the card before paying
	var thing = random_card() if item == Item.card else item
	if !add_to_inventory(thing):
		return 0
	player_loseMoney(getCost(item))
	return 1

func add_heat():
	SoundManager.play_music(chaseMusic)
	SoundManager.play_sfx(alarmSfx)
	heat = HEAT_TIME

# a random playing card for the inventory
func random_card():
	var suits = ["Clubs", "Spades", "Diamonds", "Hearts"]
	var values = [2, 3, 4, 5, 6, 7, 8, 9, 10, "Jack", "Queen", "King", "Ace"]
	return {"suit": suits.pick_random(), "value": values.pick_random()}

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
	heat = max(heat - delta, 0)
	head_start = max(head_start - delta, 0)
	# debug: space pretends you are cheating
	#if Input.is_action_just_pressed("debug_cheat_caught"):
		#add_heat()

func _on_dialogue_started(dialogue) -> void:
	is_dialogue_running = true

func _on_dialogue_ended(dialogue) -> void:
	is_dialogue_running = false
	# paid the last ante, wait for the shop dialogue to finish first
	if quotas_paid >= ANTES and not has_won:
		win()
		return
	if shop_wanted:
		shop_wanted = false
		open_shop()

# scene switching: the current scene is taken out of the tree and the next one is added.
# it happens at the end of the frame (call_deferred) so nothing is removed halfway through an update
# the intro cutscene only plays the first time
func play():
	if has_seen_intro():
		go_to_casino()
	else:
		call_deferred("switch_scene", introScene.instantiate(), false)

# the intro calls this once its dialogue is over
func intro_done():
	save_seen_intro()
	go_to_casino()

# the pay clock starts when you get to the casino
func go_to_casino():	
	SoundManager.play_music(normalMusic)
	quota_timer = QUOTA_TIME
	call_deferred("switch_scene", casinoScene.instantiate(), false)

func open_shop():
	SoundManager.music_player.volume_db = 0
	SoundManager.play_music(shopMusic)
	open_scene(shopScene)

# opens a scene on top of the casino (shop, blackjack table, ...), close_scene goes back
func open_scene(scene):
	call_deferred("switch_scene", scene.instantiate(), true)

func close_scene():
	if saved_scene == null:
		return
	call_deferred("switch_scene", saved_scene, false)
	saved_scene = null

# caught cheating at a table: you're thrown back onto the floor and security comes after you.
# you only lose if a guard actually catches you out there
func caught_cheating():
	add_heat()
	head_start = HEAD_START
	if saved_scene == null:
		# nowhere to run (the table was opened on its own for testing), so it's over
		game_over()
		return
	close_scene()
	call_deferred("sound_alarm")

# the guard closest to you comes running and yells for backup
func sound_alarm():
	var player = null
	for node in get_tree().get_nodes_in_group("player"):
		if node.has_signal("caught"):
			player = node
	var closest = null
	for guard in get_tree().get_nodes_in_group("guard"):
		if guard.has_method("start_chase"):
			if closest == null or guard.global_position.distance_to(player.global_position) < closest.global_position.distance_to(player.global_position):
				closest = guard
	if closest:
		closest.start_chase(true)

# every ante paid: you're free
func win():
	has_won = true
	if saved_scene:
		saved_scene.queue_free()
		saved_scene = null
	call_deferred("switch_scene", winScene.instantiate(), false)

# back to the start screen with a fresh run (from the game over and win screens)
func back_to_menu():
	reset()
	call_deferred("switch_scene", startScene.instantiate(), false)

# puts everything back to how a new run starts.
# if you add something that changes during a run, reset it here too
func reset():
	if saved_scene:
		saved_scene.queue_free()
		saved_scene = null
	player_money = STARTING_MONEY
	quotas_paid = 0
	current_quota = BASE_QUOTA
	quota_timer = QUOTA_TIME
	current_bet = 0
	inventory = []
	inventorySpace = STARTING_INVENTORY_SPACE
	buffs = []
	firstBuy = true
	firstCards = true
	heat = 0.0
	head_start = 0.0
	shop_wanted = false
	is_game_over = false
	has_won = false
	is_dialogue_running = false

func game_over():
	if is_game_over:
		return
	is_game_over = true
	call_deferred("switch_scene", gameOverScene.instantiate(), false)

func broke():
	is_game_over = true
	call_deferred("switch_scene", gameOverScene.instantiate(), false)

func has_seen_intro():
	var save = ConfigFile.new()
	save.load(SAVE_PATH)
	return save.get_value("progress", "seen_intro", false)

func save_seen_intro():
	var save = ConfigFile.new()
	save.load(SAVE_PATH)
	save.set_value("progress", "seen_intro", true)
	save.save(SAVE_PATH)

func play_death():
	SoundManager.play_sfx(deathSfx)
	
func play_whoosh():
	SoundManager.play_sfx(transitionSfx)

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
	
