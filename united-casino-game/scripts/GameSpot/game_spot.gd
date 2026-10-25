extends Node2D

# a spot in the casino where you can play a game, like the blackjack table.
# a little arrow bobs over it so people can tell it's there

@export var game_scene: PackedScene
@export var game_name = "Blackjack"

@onready var arrow = $Arrow
var player_near = false
var time = 0.0


func _process(delta: float) -> void:
	# bob the arrow up and down
	time += delta
	arrow.position.y = -190 + sin(time * 4) * 8


# the player can use this while standing close enough
func can_interact():
	return player_near


# what the E prompt says
func prompt_text():
	return "Play " + game_name


# called by the player when this gets used (E or clicking on it)
func interact():
	GameManager.open_scene(game_scene)


func _on_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_near = true


func _on_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_near = false
