extends CanvasLayer

@onready var money_label = $Stack/Panel/VBox/MoneyLabel
@onready var goal_label = $Stack/Panel/VBox/GoalLabel
@onready var time_label = $Stack/Panel/VBox/TimeLabel
@onready var time_bar = $Stack/Panel/VBox/TimeBar
@onready var heat_label = $Stack/Panel/VBox/HeatLabel
@onready var slots = $Stack/InventoryPanel/VBox/Slots
#@onready var buffs_label = $Stack/InventoryPanel/VBox/BuffsLabel

const card_scene = preload("res://scenes/card.tscn")
const EMF_ICON = preload("res://assets/sprites/emf.png")
const SLOT_SIZE = Vector2(68, 96)
const SLOT_GAP = 12

# what the inventory looked like last time it was drawn
var shown_inventory = null
var shown_space = 0

func _process(delta):
	money_label.text = "Money: $%d" % GameManager.player_money
	goal_label.text = "Ante %d/%d: pay $%d" % [GameManager.quotas_paid + 1, GameManager.ANTES, GameManager.current_quota]

	# the bar empties as the time to pay runs out
	var seconds = int(ceil(GameManager.quota_timer))
	time_label.text = "Pay in %d:%02d" % [int(seconds / 60.0), seconds % 60]
	time_bar.max_value = GameManager.QUOTA_TIME
	time_bar.value = GameManager.quota_timer

	# shows how long guards will chase you on sight after a cheat
	heat_label.visible = GameManager.heat > 0
	heat_label.text = "Security's onto you: %ds" % ceil(GameManager.heat)

	# only redraw the inventory when something in it changed
	if GameManager.inventory != shown_inventory or GameManager.inventorySpace != shown_space:
		show_inventory()
	#buif GameManager.buffs.is_empty():
		#buffs_label.text = ""
	#else:
		#buffs_label.text = "Buffs: " + ", ".join(GameManager.buffs)


# draws an empty slot for every inventory space, with the card in it if there is one
func show_inventory():
	shown_inventory = GameManager.inventory.duplicate()
	shown_space = GameManager.inventorySpace
	for child in slots.get_children():
		child.queue_free()
	for i in GameManager.inventorySpace:
		var slot = ColorRect.new()
		slot.color = Color(1, 1, 1, 0.1)
		slot.position = slot_position(i)
		slot.size = SLOT_SIZE
		slots.add_child(slot)
		if i >= GameManager.inventory.size():
			continue
		var item = GameManager.inventory[i]
		var middle = slot.position + SLOT_SIZE / 2
		if item is Dictionary:
			var card = card_scene.instantiate()
			card.setup(item.suit, item.value)
			card.scale = Vector2(0.4, 0.4)
			slots.add_child(card)
			card.change_sprite(middle.x, middle.y)
		elif item == GameManager.Item.emf:
			var icon = Sprite2D.new()
			icon.texture = EMF_ICON
			icon.scale = Vector2(6, 6)
			icon.position = middle
			slots.add_child(icon)


func slot_position(i):
	return Vector2(i * (SLOT_SIZE.x + SLOT_GAP), 4)


# which inventory slot is under this screen position, -1 if none
func inventory_item_at(screen_position):
	for i in GameManager.inventory.size():
		if Rect2(slots.global_position + slot_position(i), SLOT_SIZE).has_point(screen_position):
			return i
	return -1
