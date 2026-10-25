extends Node2D

@onready var entered = false
@onready var to_zeroed = false
@onready var player = get_node_or_null("../Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if to_zeroed and player and player.is_hidden:
		# slide into the spot and stop exactly on it (overshooting made the screen shake)
		player.global_position = player.global_position.move_toward(global_position, 300 * delta)
		if player.global_position == global_position:
			to_zeroed = false
	if player and player.is_hidden and position.distance_to(player.position) < 5:
		player.sprite.animation = "front"

# the player can press E on this while standing in it
func can_interact():
	return entered and player != null

# what the E prompt says for this
func prompt_text():
	return "Get out" if player.is_hidden else "Hide"

# called by the player when E is pressed and this is the closest thing to them
func interact():
	# press interact again to come back out
	player.is_hidden = not player.is_hidden
	# inside the trash can nothing bumps into you (bumping made the screen shake)
	player.get_node("CollisionShape2D").set_deferred("disabled", player.is_hidden)
	if player.is_hidden:
		player.sprite.modulate.a = 0.4
	else:
		player.sprite.modulate.a = 1
		player.sprite.animation = "front"
		player.velocity = Vector2.ZERO
	print("HIDING" if player.is_hidden else "LEFT HIDING SPOT")
	to_zeroed = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		entered = true
		#player = area.get_parent()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		entered = false
		#player = null
