extends Control

var user_data

@export var score_label: Label
@export var falls_label: Label
@export var vanquishes_label: Label
@export var level_label: Label

@export var update_interval: float = 1.0  # Update interval in seconds
@onready var timer = Timer.new()

func _ready():
	user_data = get_node("/root/UserData")
	add_child(timer)
	timer.set_wait_time(update_interval)
	timer.set_autostart(true)
	timer.set_one_shot(false)
	timer.connect("timeout", Callable(self, "update_hud"))
	timer.start()
	update_hud()

func update_hud():
	if user_data:
		var user_data_dict = user_data.getUserData()
		score_label.text = "Score: " + str(user_data_dict["game_score"])
		falls_label.text = "Falls: " + str(user_data_dict["game_falls"])
		vanquishes_label.text = "Vanquishes: " + str(user_data_dict["game_vanquishes"])
		level_label.text = "Level: " + str(user_data_dict["game_level"])
