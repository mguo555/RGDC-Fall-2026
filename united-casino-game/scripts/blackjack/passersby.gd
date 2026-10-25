extends Node2D

# GUARDS AND GAMBLERS WALK PAST BEHIND THE DEALER, SOMETIMES A FEW AT ONCE.
# GAMBLERS DON'T CARE WHAT YOU DO. GUARDS ONLY SEE YOU WHILE THEY STOP AND LOOK AT YOUR TABLE
const GUARD_SHEETS = [
	preload("res://assets/sprites/guard1_sheet.png"),
	preload("res://assets/sprites/guard2_sheet.png"),
	preload("res://assets/sprites/guard3_sheet.png"),
]
const GAMBLER_SHEET = preload("res://assets/sprites/npc_sheet.png")
const SIZE = 6
const WALK_Y = 520
# HOW OFTEN A GUARD WALKING PAST STOPS TO LOOK AT YOUR TABLE
const LOOK_CHANCE = 0.6

var spawn_timer = 2.0


func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_passerby()
		spawn_timer = randf_range(1.5, 5.0)


func spawn_passerby():
	var person = Passerby.new()
	person.is_guard = randf() < 0.5
	person.texture = GUARD_SHEETS.pick_random() if person.is_guard else GAMBLER_SHEET
	person.hframes = 4
	person.vframes = 4
	person.scale = Vector2(SIZE, SIZE)
	person.speed = randf_range(180, 360)
	person.walk_y = WALK_Y
	# FLIPPED SPRITES FACE LEFT, SO THEY START ON THE RIGHT AND WALK LEFT
	person.flip_h = randf() < 0.5
	person.position = Vector2(2200 if person.flip_h else -280, WALK_Y)
	# GUARDS ONLY STOP WHERE YOU CAN SEE THEM, LEFT OR RIGHT OF THE DEALER (NOT BEHIND HIM)
	if person.is_guard and randf() < LOOK_CHANCE:
		person.look_at_x = [randf_range(220, 440), randf_range(1460, 1700)].pick_random()
	add_child(person)


func anyone_watching():
	for person in get_children():
		if person.is_looking():
			return true
	return false
