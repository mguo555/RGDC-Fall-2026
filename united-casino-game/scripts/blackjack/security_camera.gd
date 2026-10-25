extends Sprite2D

# the security camera sweeps left and right. it can only see you while it faces the screen
const FPS = 12
const FRAME_COUNT = 151
# the frames where the lens points at you (the narrowest frames on the sheet)
const LOOKING_FRAMES = [[0, 13], [72, 77], [134, 150]]

var time = 0.0


func _process(delta: float) -> void:
	time += delta
	frame = int(time * FPS) % FRAME_COUNT
	# goes red while it's looking at you
	modulate = Color(1, 0.55, 0.55) if is_looking() else Color.WHITE


func is_looking():
	for part in LOOKING_FRAMES:
		if frame >= part[0] and frame <= part[1]:
			return true
	return false
