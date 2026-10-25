extends CharacterBody2D

@export var patrol_path: Path2D
var speed
var wait_time

@onready var sprite = $AnimatedSprite2D

const CATCH_DISTANCE = 150
const SIGHT_DISTANCE = 150 * 2
const LOSE_SIGHT_DISTANCE = 150 * 5
const PATROL_POINTS = [Vector2(800, 800), Vector2(200, 200), Vector2(800, 200), Vector2(200, 800)]

var points = PATROL_POINTS
var target = 0
var wait_timer = 0.0
var chase = false


func _ready() -> void:
	#for i in patrol_path.curve.point_count:
		#points.append(patrol_path.to_global(patrol_path.curve.get_point_position(i)))
	speed = 500
	wait_time = 10.0


# the player is the node in the "player" group that has the caught signal
# (the player's child nodes are in the group too)
func find_player():
	for node in get_tree().get_nodes_in_group("player"):
		if node.has_signal("caught"):
			return node
	return null


func stop_chase():
	chase = false
	points = PATROL_POINTS
	target = 0


func _physics_process(delta: float) -> void:
	var player = find_player()
	if player:
		var distance = player.global_position.distance_to(global_position)
		if chase:
			if player.is_hidden or distance > LOSE_SIGHT_DISTANCE:
				print("Lost them...")
				stop_chase()
			elif distance < CATCH_DISTANCE:
				print("CAUGHT!!!")
				player.caught.emit()
				stop_chase()
			else:
				points = [player.global_position]
				target = 0
		elif Input.is_action_just_pressed("debug_cheat_caught"):
			if player.is_hidden:
				print("Can't see anyone")
			elif distance <= SIGHT_DISTANCE:
				chase = true
				print("I SAW YOU!!!")
			else:
				print("Too far")
	velocity = Vector2.ZERO

	#print(wait_time)

	#print(target, " ", points.size())
	if wait_timer > 0:
		wait_timer -= delta
	elif global_position.distance_to(points[target]) <= speed * delta:
		wait_timer = wait_time

		target = (target + 1) % points.size()
	else:
		velocity = global_position.direction_to(points[target]) * speed

	move_and_slide()

	if velocity == Vector2.ZERO:
		sprite.set_frame_and_progress(0, 0)
	elif abs(velocity.x) > abs(velocity.y):
		sprite.flip_h = velocity.x < 0
		sprite.play("side")
	elif velocity.y < 0:
		sprite.play("back")
	else:
		sprite.play("front")
