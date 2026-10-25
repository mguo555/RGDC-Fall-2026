extends Node2D

@onready var entered = false
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and entered and player:
		# press interact again to come back out
		player.is_hidden = not player.is_hidden
		player.modulate.a = 0.4 if player.is_hidden else 1.0
		print("HIDING" if player.is_hidden else "LEFT HIDING SPOT")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		entered = true
		player = area.get_parent()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		entered = false
		player = null
