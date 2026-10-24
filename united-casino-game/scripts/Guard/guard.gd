extends CharacterBody2D

@export var patrol_path: Path2D
var speed
var wait_time

@onready var sprite = $AnimatedSprite2D

var points = []
var target = 0
var wait_timer = 0.0
var chase = false
var player_pos = Vector2(0, 0)


func _ready() -> void:
	#for i in patrol_path.curve.point_count:
		#points.append(patrol_path.to_global(patrol_path.curve.get_point_position(i)))
	speed = 500
	wait_time = 1.0


func _physics_process(delta: float) -> void:
	if get_tree().current_scene.has_node("Player"):
		print(chase)
		if chase:
			player_pos = get_tree().current_scene.find_child("Player").position
			points = [player_pos]
			target = 0
			if player_pos.distance_to(position) < 150:
				print("CAUGHT!!!")
			else:
				print("Chasing")
			if player_pos.distance_to(position) > 150*5:
				chase = false
		else:
			points = [Vector2.ZERO, Vector2(700, 700), Vector2(700, 0), Vector2(0, 700)]
			print("Not chasing")
			if Input.is_action_pressed("debug_cheat_caught"):
				if player_pos.distance_to(position) > 150*2:
					chase = true
					print("I SAW YOU!!!")
				else:
					print("Too far")
	velocity = Vector2.ZERO

	print(wait_time)

	print(target, " ", points.size())
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
