extends Sprite2D
class_name Passerby

# SOMEONE WALKING PAST BEHIND THE DEALER.
# GUARDS SOMETIMES STOP AND TURN TO LOOK AT YOUR TABLE, THAT'S THE ONLY TIME THEY CAN SEE YOU CHEAT

var speed = 250
var walk_y = 0.0
var is_guard = false
var look_at_x = -1.0 # WHERE A GUARD STOPS TO LOOK, -1 IF THEY JUST WALK BY
var look_timer = 0.0


func _process(delta):
	if look_timer > 0:
		# STANDING STILL, FACING YOUR TABLE
		look_timer -= delta
		frame = 0
		position.y = walk_y
		return

	var direction = -1 if flip_h else 1
	position.x += direction * speed * delta
	# BOB UP AND DOWN AND STEP THROUGH THE 4 WALKING FRAMES (ROW 2 OF THE SHEET)
	position.y = walk_y + sin(position.x / 25.0) * 12
	frame = 4 + int(abs(position.x) / 40) % 4

	# STOP ONCE AT THE LOOKING SPOT
	if look_at_x >= 0 and abs(position.x - look_at_x) < speed * delta:
		look_timer = randf_range(1.0, 2.5)
		look_at_x = -1

	if position.x < -300 or position.x > 2220:
		queue_free()


func is_looking():
	return is_guard and look_timer > 0
