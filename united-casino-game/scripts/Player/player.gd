extends CharacterBody2D

@onready var money = $".".get_meta("money")
@onready var inventory = $".".get_meta("inventory")
@onready var animation = "front"

const SPEED = 600

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	money = $".".get_meta("metadata/money")
	print(money)

	velocity.x = 0
	velocity.y = 0
	var x = 0
	var y = 0
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
