extends CanvasLayer
@onready var playerStats: Label = $CenterContainer/VBoxContainer/PlayerStats

func _on_game_manager_updated_ui() -> void:
	print("Signal received")
	print("CanvasLayer:", GameManager.player_money)
	playerStats.text = "Money: {money} \n Inventory: {inventory}".format({"money": GameManager.player_money, "inventory": GameManager.inventory})
