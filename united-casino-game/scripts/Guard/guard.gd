extends CharacterBody2D

# each guard type has its own personality, like the pacman ghosts
enum Type { CHASER, AMBUSHER, SLACKER }
@export var type: Type = Type.CHASER
# the points this guard walks between, can be different for every guard
@export var patrol_points: Array[Vector2] = [Vector2.ZERO, Vector2(700, 700), Vector2(700, 0), Vector2(0, 700)]

# speed: how fast they walk, sight: how far away they can spot you,
# lose_sight: how far you have to get to escape, patience: seconds they chase before giving up
const TYPES = {
	Type.CHASER: {"speed": 520, "sight": 320, "lose_sight": 750, "patience": 12.0}, # grey, runs straight at you
	Type.AMBUSHER: {"speed": 460, "sight": 420, "lose_sight": 900, "patience": 9.0}, # pink, cuts you off ahead
	Type.SLACKER: {"speed": 360, "sight": 240, "lose_sight": 550, "patience": 5.0}, # green, slow, gives up fast
}

var speed
var wait_time
var sight_distance
var lose_sight_distance
var patience
var patience_timer = 0.0

@onready var sprite = $AnimatedSprite2D
@onready var nav = $NavigationAgent2D

const CATCH_DISTANCE = 150
# a guard who spots you yells, and guards this close join the chase
const YELL_RADIUS = 600
# how far ahead of the player the ambusher aims
const AMBUSH_DISTANCE = 250
# how close the guard has to walk past a hiding spot to think about checking it
const CHECK_DISTANCE = 200
# if it should be walking but has barely moved for this long, the way is blocked
const STUCK_TIME = 5.0
# the halls the guard sweeps through after the player hides
const SEARCH_POINTS = [Vector2(160, 250), Vector2(700, 230), Vector2(1580, 230), Vector2(1580, 650), Vector2(700, 500), Vector2(450, 712), Vector2(180, 500)]

var points = []
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
	speed = TYPES[type].speed
	sight_distance = TYPES[type].sight
	lose_sight_distance = TYPES[type].lose_sight
	patience = TYPES[type].patience
	wait_time = 1.0
	points = patrol_points
	nav.target_position = points[target]


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
	go_to(patrol_points, 0)


# only the guard who spots you yells. guards that join from a yell don't yell again,
# so one sighting can't chain across the whole casino
func start_chase(yell):
	if state == "chase":
		return
	state = "chase"
	wait_timer = 0
	patience_timer = patience
	if yell:
		print("HEY! Stop right there!")
		for guard in get_tree().get_nodes_in_group("guard"):
			if guard != self and guard.has_method("start_chase") and global_position.distance_to(guard.global_position) < YELL_RADIUS:
				guard.start_chase(false)


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


func chase_player(player, delta):
	var distance = player.global_position.distance_to(global_position)
	patience_timer -= delta
	if player.is_hidden:
		print("Where did they go?")
		start_search()
	elif distance > lose_sight_distance:
		print("Lost them...")
		start_patrol()
	elif patience_timer <= 0:
		print("Ugh, not worth it.")
		start_patrol()
	elif distance < CATCH_DISTANCE:
		print("CAUGHT!!!")
		player.caught.emit()
		start_patrol()
	elif type == Type.AMBUSHER:
		# aim where the player is heading to cut them off
		points = [player.global_position + player.velocity.normalized() * AMBUSH_DISTANCE]
		target = 0
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
	if type == Type.SLACKER:
		# wanders his route in no particular order
		target = randi() % points.size()
	else:
		target = (target + 1) % points.size()


func _physics_process(delta: float) -> void:
	var player = find_player()
	if player:
		if state == "chase":
			chase_player(player, delta)
		elif Input.is_action_just_pressed("debug_cheat_caught"):
			var distance = player.global_position.distance_to(global_position)
			if player.is_hidden:
				print("Can't see anyone")
			elif distance <= sight_distance:
				print("I SAW YOU!!!")
				start_chase(true)
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
