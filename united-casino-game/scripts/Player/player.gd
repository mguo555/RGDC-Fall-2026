extends CharacterBody2D

@onready var animation = "front"

const SPEED = 600

# emitted when a security guard catches the player
signal caught

# true while the player is in a hiding spot (guards can't see them)
var is_hidden = false

@onready var sprite = $AnimatedSprite2D
@onready var game_manager = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.x = 0
	velocity.y = 0
	if is_hidden:
		sprite.set_frame_and_progress(0, 0)
		return
	var x = 0
	var y = 0
	
	if !(game_manager.is_dialogue_running()):
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

func _physics_process(delta: float) -> void:
	move_and_slide()
