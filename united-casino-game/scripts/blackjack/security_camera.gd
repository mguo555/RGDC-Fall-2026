extends Sprite2D

# the security camera sweeps left and right. it can only see you while it faces the screen
const FPS = 12
const FRAME_COUNT = 151
# the frames where the lens points at you (the narrowest frames on the sheet)
const LOOKING_FRAMES = [[0, 13], [72, 77], [134, 150]]
# an EMF knocks the camera out for this long
const OFF_TIME = 30.0

var time = 0.0
var off_timer = 0.0


func _process(delta: float) -> void:
	if off_timer > 0:
		# knocked out: stops moving and goes dark
		off_timer -= delta
		modulate = Color(0.3, 0.3, 0.3)
		return
	time += delta
	frame = int(time * FPS) % FRAME_COUNT
	# goes red while it's looking at you
	modulate = Color(1, 0.55, 0.55) if is_looking() else Color.WHITE


func knock_out():
	off_timer = OFF_TIME


func is_looking():
	if off_timer > 0:
		return false
	for part in LOOKING_FRAMES:
		if frame >= part[0] and frame <= part[1]:
			return true
	return false
