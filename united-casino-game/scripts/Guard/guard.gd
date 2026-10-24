extends CharacterBody2D

@export var patrol_path: Path2D
@export var speed = 300
@export var wait_time = 1.0

@onready var sprite = $AnimatedSprite2D

var points = []
var target = 0
var wait_timer = 0.0


func _ready() -> void:
	#for i in patrol_path.curve.point_count:
		#points.append(patrol_path.to_global(patrol_path.curve.get_point_position(i)))
	pass

func _physics_process(delta: float) -> void:
	points = [Vector2.ZERO, Vector2(700, 700), Vector2(700, 0), Vector2(0, 700)]
	velocity = Vector2.ZERO

	if wait_timer > 0:
		wait_timer -= delta
	elif global_position.distance_to(points[target]) <= speed * delta:
		wait_timer = wait_time
		target = (target + 1) % points.size()
	else:
		velocity = global_position.direction_to(points[target]) * speed

	move_and_slide()

	if velocity == Vector2.ZERO:
		sprite.play("idle")
	elif abs(velocity.x) > abs(velocity.y):
		sprite.flip_h = velocity.x < 0
		sprite.play("side")
	elif velocity.y < 0:
		sprite.play("back")
	else:
		sprite.play("front")
