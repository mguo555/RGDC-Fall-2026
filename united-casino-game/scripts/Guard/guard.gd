extends CharacterBody2D

@export var patrol_path: Path2D
var speed
var wait_time

@onready var sprite = $AnimatedSprite2D
@onready var nav = $NavigationAgent2D

const CATCH_DISTANCE = 150
const SIGHT_DISTANCE = 150 * 2
const LOSE_SIGHT_DISTANCE = 150 * 5
# how close the guard has to walk past a hiding spot to think about checking it
const CHECK_DISTANCE = 200
# if it should be walking but has barely moved for this long, the way is blocked
const STUCK_TIME = 5.0
const PATROL_POINTS = [Vector2.ZERO, Vector2(700, 700), Vector2(700, 0), Vector2(0, 700)]
# the halls the guard sweeps through after the player hides
const SEARCH_POINTS = [Vector2(160, 250), Vector2(700, 230), Vector2(1580, 230), Vector2(1580, 650), Vector2(700, 500), Vector2(450, 712), Vector2(180, 500)]

var points = PATROL_POINTS
var target = 0
var wait_timer = 0.0
var stuck_timer = 0.0

# "patrol", "chase", "search" (sweeping the halls) or "check" (walking to a hiding spot)
var state = "patrol"
var search_points_left = 0
# hiding spots the guard already rolled for during this search
var rolled_spots = []
var spot_to_check = null


func _ready() -> void:
	#for i in patrol_path.curve.point_count:
		#points.append(patrol_path.to_global(patrol_path.curve.get_point_position(i)))
	speed = 500
	nav.target_position = points[target]
	wait_time = 1.0


# the player is the node in the "player" group that has the caught signal
# (the player's child nodes are in the group too)
func find_player():
	for node in get_tree().get_nodes_in_group("player"):
		if node.has_signal("caught"):
			return node
	return null


func go_to(new_points, first_target):
	points = new_points
	target = first_target
	wait_timer = 0


func start_patrol():
	state = "patrol"
	go_to(PATROL_POINTS, 0)


func start_search():
	state = "search"
	rolled_spots = []
	search_points_left = SEARCH_POINTS.size()
	go_to(SEARCH_POINTS, closest_point(SEARCH_POINTS))


func closest_point(list):
	var best = 0
	for i in list.size():
		if global_position.distance_to(list[i]) < global_position.distance_to(list[best]):
			best = i
	return best


func chase_player(player):
	var distance = player.global_position.distance_to(global_position)
	if player.is_hidden:
		print("Where did they go?")
		start_search()
	elif distance > LOSE_SIGHT_DISTANCE:
		print("Lost them...")
		start_patrol()
	elif distance < CATCH_DISTANCE:
		print("CAUGHT!!!")
		player.caught.emit()
		start_patrol()
	else:
		points = [player.global_position]
		target = 0


# every hiding spot the guard walks past during a search gets one roll to be checked
func roll_for_hiding_spots():
	for spot in get_tree().get_nodes_in_group("hiding_spot"):
		if spot in rolled_spots or global_position.distance_to(spot.global_position) > CHECK_DISTANCE:
			continue
		rolled_spots.append(spot)
		if randf() < GameManager.hiding_spot_check_chance:
			print("Let me check in there...")
			state = "check"
			spot_to_check = spot
			go_to([spot.global_position], 0)
			return


func check_hiding_spot():
	var player = find_player()
	if player and player.is_hidden and spot_to_check.entered:
		print("Found you!")
		player.caught.emit()
		start_patrol()
	else:
		print("Nobody in here.")
		state = "search"
		go_to(SEARCH_POINTS, closest_point(SEARCH_POINTS))


# the way to the current point is blocked, so move on to the next one
func path_blocked():
	print("Something's in the way...")
	if state == "check":
		# can't get to the trash can, keep searching instead
		state = "search"
		go_to(SEARCH_POINTS, closest_point(SEARCH_POINTS))
	elif state != "chase":
		reached_point()


# called when the guard gets to the point it was walking to
func reached_point():
	if state == "check":
		check_hiding_spot()
		return
	if state == "search":
		search_points_left -= 1
		if search_points_left <= 0:
			print("Must have been nothing.")
			start_patrol()
			return
	wait_timer = wait_time
	target = (target + 1) % points.size()


func _physics_process(delta: float) -> void:
	var player = find_player()
	if player:
		if state == "chase":
			chase_player(player)
		elif Input.is_action_just_pressed("debug_cheat_caught"):
			var distance = player.global_position.distance_to(global_position)
			if player.is_hidden:
				print("Can't see anyone")
			elif distance <= SIGHT_DISTANCE:
				state = "chase"
				wait_timer = 0
				print("I SAW YOU!!!")
			else:
				print("Too far")
	if state == "search":
		roll_for_hiding_spots()
	elif state == "check" and global_position.distance_to(spot_to_check.global_position) < CATCH_DISTANCE:
		# close enough to look inside (a hidden player blocks the guard from the exact spot)
		check_hiding_spot()
	velocity = Vector2.ZERO

	# only set a new target when it changes, setting it makes the agent plan a new path
	if nav.target_position != points[target]:
		nav.target_position = points[target]

	# stand still during conversations
	if GameManager.is_dialogue_running:
		pass
	elif wait_timer > 0:
		wait_timer -= delta
	elif nav.is_navigation_finished():
		reached_point()
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
		path_blocked()

	if velocity == Vector2.ZERO:
		sprite.set_frame_and_progress(0, 0)
	elif abs(velocity.x) > abs(velocity.y):
		sprite.flip_h = velocity.x < 0
		sprite.play("side")
	elif velocity.y < 0:
		sprite.play("back")
	else:
		sprite.play("front")
