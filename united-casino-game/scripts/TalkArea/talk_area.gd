extends Area2D

# put this in any npc to make them talkable with E, like in pokemon.
# pick the dialogue file and the title to start from in the inspector
@export var dialogue: DialogueResource
@export var cue = "talk"

var player_near = false


# the player can press E while standing close enough
func can_interact():
	return player_near


# what the E prompt says
func prompt_text():
	return "Talk"


# called by the player when E is pressed and this npc is the closest thing to them
func interact():
	DialogueManager.show_dialogue_balloon(dialogue, cue, [GameManager])


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_near = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_near = false
