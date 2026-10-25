extends CharacterBody2D

# someone gambling at the casino. they wander between random spots,
# and you can talk to them with E (their TalkArea)
# TODO (Matthew): bribing a gambler to swap clothes with you should make chasing guards lose you
# (something like: every guard that is chasing calls start_search(), and GameManager.heat = 0)

# where they wander around, in world positions
@export var wander_area = Rect2(200, 250, 1400, 450)
@export var speed = 250

@onready var sprite = $AnimatedSprite2D
@onready var nav = $NavigationAgent2D

# if it should be walking but has barely moved for this long, the way is blocked
const STUCK_TIME = 5.0

var wait_timer = 0.0
var stuck_timer = 0.0


func _ready() -> void:
	pick_new_spot()


# picks somewhere random to walk to next, after hanging around for a bit
func pick_new_spot():
	nav.target_position = wander_area.position + Vector2(randf() * wander_area.size.x, randf() * wander_area.size.y)
	wait_timer = randf_range(1.0, 4.0)


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO

	# stand still during conversations
	if GameManager.is_dialogue_running:
		pass
	elif wait_timer > 0:
		wait_timer -= delta
	elif nav.is_navigation_finished():
		pick_new_spot()
	else:
		velocity = global_position.direction_to(nav.get_next_path_position()) * speed

	var start_position = global_position
	var should_move = velocity.length() * delta
	move_and_slide()

	# moving less than a quarter of what it should means something is in the way
	if should_move > 0 and global_position.distance_to(start_position) < should_move / 4:
		stuck_timer += delta
	else:
		stuck_timer = 0
	if stuck_timer > STUCK_TIME:
		stuck_timer = 0
		pick_new_spot()

	if velocity == Vector2.ZERO:
		sprite.set_frame_and_progress(0, 0)
	elif abs(velocity.x) > abs(velocity.y):
		sprite.flip_h = velocity.x < 0
		sprite.play("side")
	elif velocity.y < 0:
		sprite.play("back")
	else:
		sprite.play("front")
