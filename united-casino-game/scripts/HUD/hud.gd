extends CanvasLayer

@onready var money_label = $Panel/VBox/MoneyLabel
@onready var goal_label = $Panel/VBox/GoalLabel
@onready var time_label = $Panel/VBox/TimeLabel
@onready var time_bar = $Panel/VBox/TimeBar

func _process(delta):
	money_label.text = "Money: $%d" % GameManager.player_money
	goal_label.text = "Round %d goal: $%d" % [GameManager.quotas_paid + 1, GameManager.current_quota]

	# the bar empties as the time to pay runs out
	var seconds = int(ceil(GameManager.quota_timer))
	time_label.text = "Pay in %d:%02d" % [int(seconds / 60.0), seconds % 60]
	time_bar.max_value = GameManager.QUOTA_TIME
	time_bar.value = GameManager.quota_timer
