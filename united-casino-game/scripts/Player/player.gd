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
	var mouse_pos = get_global_mouse_position()

	var left = position.x < mouse_pos.x
	
	var true_x = position.x - mouse_pos.x
	var true_y = position.y - mouse_pos.y
	var x = abs(true_x)
	var y = abs(true_y)
	
	var a = x
	var o = y
	
	var h = (a**2 + o**2)**0.5
	
	velocity.x = a/h * SPEED * -true_x / x
	velocity.y = o/h * SPEED * -true_y / y
	
	if cooling_time > 0:
		cooling_time -= delta

	# animation if statements
	if (x**2 + y**2)**0.5 < 50:
		sprite.animation = "idle"
		sprite.play()
		velocity.x = 0
		velocity.y = 0
	elif (true_y / x) > 3.5:
		sprite.animation = "back"
		sprite.play()
		sprite.flip_h = false
	elif (true_y / x) < -3.5:
		sprite.animation = "front"
		sprite.play()
		sprite.flip_h = false
	elif not left:
		sprite.animation = "side"
		sprite.play()
		sprite.flip_h = true
	else:
		sprite.animation = "side"
		sprite.play()
		sprite.flip_h = false
	# deadzone implementation
	
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
