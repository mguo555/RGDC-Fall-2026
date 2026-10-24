extends CharacterBody2D

var health = 3
var cd = 0.5
var cooling_time = 0
const SPEED = 600
var ouch_time = 0
var i_frames = 0
signal attention(pos)

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.x = 0
	velocity.y = 0
	var animation = "idle"
	if Input.is_action_pressed("move_up"):
		animation = "back"
		sprite.flip_h = false
		velocity.y = -1 * SPEED
	if Input.is_action_pressed("move_down"):
		animation = "front"
		sprite.flip_h = false
		velocity.y = 1 * SPEED
	if Input.is_action_pressed("move_left"):
		animation = "side"
		sprite.flip_h = true
		velocity.x = -1 * SPEED
	if Input.is_action_pressed("move_right"):
		animation = "side"
		sprite.flip_h = false
		velocity.x = 1 * SPEED
	if velocity.length() == 0:
		sprite.animation = "idle"
	sprite.animation = animation
	sprite.play()
	
	if velocity.x != 0 or velocity.y != 0:
		attention.emit()

	if ouch_time > 0:
		ouch_time -= delta
		if ouch_time <= 0:
			sprite.modulate = Color(1,1,1,1)
	if i_frames > 0:
		i_frames -= delta
		
	# win check
	#if ($winCheck/CollisionShape2D.)

func _physics_process(delta: float) -> void:
	move_and_slide()
