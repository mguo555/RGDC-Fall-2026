extends Node2D

@onready var entered = false
@onready var to_zeroed = false
@onready var player = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and entered and player:
		# press interact again to come back out
		player.is_hidden = not player.is_hidden
		if player.is_hidden:
			player.modulate.a = 0.4
		else:
			player.modulate.a = 1
			player.sprite.animation = "front"
			player.velocity = Vector2.ZERO
		print("HIDING" if player.is_hidden else "LEFT HIDING SPOT")
		to_zeroed = true
	if to_zeroed and player and player.is_hidden:
		if position.distance_to(player.position) > 0:
			print("moving")
			var angle = player.position.direction_to(position)
			player.velocity = 300 * angle
			player._physics_process(delta)
		else:
			to_zeroed = false
	if player.is_hidden and position.distance_to(player.position) < 5:
		player.sprite.animation = "front"

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		entered = true
		#player = area.get_parent()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		entered = false
		#player = null
