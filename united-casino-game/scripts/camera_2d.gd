extends Camera2D

@onready var player = $"../Duck"

@export var smoothing: float = 3

func _ready() -> void:
	set_as_top_level(true)

func _process(delta: float) -> void:
	var player_gpos = player.global_position
	global_position = player_gpos
