extends CharacterBody2D

@onready var animation = "front"

const SPEED = 600
# how close to the middle of something a click has to land to count as clicking on it
const CLICK_RADIUS = 70

# emitted when a security guard catches the player
signal caught

# true while the player is in a hiding spot (guards can't see them)
var is_hidden = false

@onready var sprite = $AnimatedSprite2D
@onready var prompt = $InteractPrompt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# getting caught by a guard ends the game
	caught.connect(GameManager.game_over)

# the closest thing in range that E would use right now (trash can, Mr. Shady, ...), or null
func find_closest_interactable():
	var closest = null
	var closest_distance = INF
	for thing in get_tree().get_nodes_in_group("interactable"):
		var distance = global_position.distance_to(thing.global_position)
		if thing.can_interact() and distance < closest_distance:
			closest = thing
			closest_distance = distance
	return closest

# the thing at click_position, if the player is close enough to use it, or null
func find_clicked_interactable(click_position):
	for thing in get_tree().get_nodes_in_group("interactable"):
		if thing.can_interact() and click_position.distance_to(thing.global_position) < CLICK_RADIUS:
			return thing
	return null

# E uses the closest thing in range, clicking uses the thing you clicked on.
# unhandled so clicks on the dialogue box and buttons don't count
func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_dialogue_running:
		return

	var thing = null
	if event.is_action_pressed("interact"):
		thing = find_closest_interactable()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		thing = find_clicked_interactable(get_global_mouse_position())

	if thing:
		get_viewport().set_input_as_handled()
		thing.interact()

# shows "E: Hide", "E: Talk", ... above whatever E would use
func update_prompt():
	var closest = find_closest_interactable()
	prompt.visible = closest != null and not GameManager.is_dialogue_running
	if prompt.visible:
		prompt.text = "E: " + closest.prompt_text()
		prompt.reset_size()
		prompt.position = closest.global_position - Vector2(prompt.size.x / 2, 110)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_prompt()
	velocity.x = 0
	velocity.y = 0
	if is_hidden:
		# the hiding spot takes care of the sprite while you're in the can
		return
	var x = 0
	var y = 0
	
	if not GameManager.is_dialogue_running:
		if Input.is_action_pressed("move_up"):
			animation = "back"
			sprite.flip_h = false
			y += -1
		if Input.is_action_pressed("move_down"):
			animation = "front"
			sprite.flip_h = false
			y += 1
		if Input.is_action_pressed("move_left"):
			animation = "side"
			sprite.flip_h = true
			x += -1
		if Input.is_action_pressed("move_right"):
			animation = "side"
			sprite.flip_h = false
			x += 1
		
		var mag = (x**2 + y**2)**0.5
		
		if mag > 0:
			velocity.x = x * SPEED / mag
			velocity.y = y * SPEED / mag
		else:
			sprite.set_frame_and_progress(0, 0)
	
		sprite.animation = animation
		sprite.play()
	else:
		sprite.set_frame_and_progress(0, 0)
func _physics_process(delta: float) -> void:
	move_and_slide()
