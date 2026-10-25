extends CharacterBody2D

var base_speed
# add sprint later if you can

# if caught by security guard
signal caught

@onready var sprite = $AnimatedSprite2D

# called every frame
func _process(delta: float) -> void:
	pass
