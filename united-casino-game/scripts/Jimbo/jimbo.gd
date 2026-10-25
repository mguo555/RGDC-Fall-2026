extends CharacterBody2D

# Jimbo is Mr. Shady: he wanders the casino and offers to sell you stuff when you talk to him

@export var patrol_path: Path2D
var speed
var wait_time
var shadyResource = load("res://dialogue/shady.dialogue")

@onready var sprite = $AnimatedSprite2D
@onready var nav = $NavigationAgent2D

# if it should be walking but has barely moved for this long, the way is blocked
const STUCK_TIME = 5.0
const PATROL_POINTS = [Vector2(800, 800), Vector2(200, 200), Vector2(800, 200), Vector2(200, 800)]

var points = PATROL_POINTS
var target = 0
var wait_timer = 0.0
var stuck_timer = 0.0
var player_near = false


func _ready() -> void:
	#for i in patrol_path.curve.point_count:
		#points.append(patrol_path.to_global(patrol_path.curve.get_point_position(i)))
	speed = 500
	nav.target_position = points[target]
	wait_time = 10.0


# unhandled so clicking through the dialogue doesn't start it again
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_near and not GameManager.is_dialogue_running:
		get_viewport().set_input_as_handled()
		DialogueManager.show_dialogue_balloon(shadyResource, "offer", [GameManager])


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO

	# only set a new target when it changes, setting it makes the agent plan a new path
	if nav.target_position != points[target]:
		nav.target_position = points[target]

	# stand still while talking to the player
	if GameManager.is_dialogue_running:
		pass
	elif wait_timer > 0:
		wait_timer -= delta
	elif nav.is_navigation_finished():
		wait_timer = wait_time

		target = (target + 1) % points.size()
	else:
		# head for the next corner of the path, the path goes around obstacles
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
		print("Can't get through, going somewhere else")
		target = (target + 1) % points.size()

	if velocity == Vector2.ZERO:
		sprite.set_frame_and_progress(0, 0)
	elif abs(velocity.x) > abs(velocity.y):
		sprite.flip_h = velocity.x < 0
		sprite.play("side")
	elif velocity.y < 0:
		sprite.play("back")
	else:
		sprite.play("front")


func _on_talk_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_near = true


func _on_talk_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_near = false
