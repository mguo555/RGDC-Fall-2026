extends Node2D

@onready var entered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and entered:
		print("HIDING")
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if "$" in area.get_groups():
		entered = true
