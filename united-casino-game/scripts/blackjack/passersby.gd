extends Node2D

# guards and gamblers walk past behind the dealer every so often.
# while one of them is on screen they can see you, so no cheating
const SHEETS = [
	preload("res://assets/sprites/guard1_sheet.png"),
	preload("res://assets/sprites/guard2_sheet.png"),
	preload("res://assets/sprites/guard3_sheet.png"),
	preload("res://assets/sprites/npc_sheet.png"),
]
const SPEED = 260
const WALK_Y = 560

var spawn_timer = 3.0


func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_passerby()
		spawn_timer = randf_range(4.0, 9.0)

	for person in get_children():
		# flipped sprites face left, so they walk left
		var direction = -1 if person.flip_h else 1
		person.position.x += direction * SPEED * delta
		# bob up and down and step through the 4 walking frames (row 2 of the sheet)
		person.position.y = WALK_Y + sin(person.position.x / 25.0) * 8
		person.frame = 4 + int(abs(person.position.x) / 40) % 4
		if person.position.x < -200 or person.position.x > 2120:
			person.queue_free()


func spawn_passerby():
	var person = Sprite2D.new()
	person.texture = SHEETS.pick_random()
	person.hframes = 4
	person.vframes = 4
	person.scale = Vector2(4, 4)
	person.flip_h = randf() < 0.5
	person.position = Vector2(2070 if person.flip_h else -150, WALK_Y)
	add_child(person)


func anyone_watching():
	for person in get_children():
		if person.position.x > 0 and person.position.x < 1920:
			return true
	return false
