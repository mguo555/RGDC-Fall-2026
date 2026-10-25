extends CharacterBody2D

@onready var animation = "front"

const SPEED = 600

# emitted when a security guard catches the player
signal caught

# true while the player is in a hiding spot (guards can't see them)
var is_hidden = false

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# getting caught by a guard ends the game
	caught.connect(GameManager.game_over)

# E goes to the closest thing in range (trash can, Mr. Shady, ...) so only one of them reacts.
# unhandled so clicking through dialogue doesn't count as pressing E
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameManager.is_dialogue_running:
		return

	var closest = null
	var closest_distance = INF
	for thing in get_tree().get_nodes_in_group("interactable"):
		var distance = global_position.distance_to(thing.global_position)
		if thing.can_interact() and distance < closest_distance:
			closest = thing
			closest_distance = distance

	if closest:
		get_viewport().set_input_as_handled()
		closest.interact()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.x = 0
	velocity.y = 0
	if is_hidden:
		sprite.set_frame_and_progress(0, 0)
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
