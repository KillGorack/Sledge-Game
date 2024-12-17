extends Control

# Reference to the singleton
var user_data

# HUD Labels
@export var score_label: Label
@export var falls_label: Label
@export var vanquishes_label: Label
@export var level_label: Label

func _ready():
	user_data = get_node("/root/UserData")
	user_data.data_updated.connect(update_hud)
	update_hud()

func update_hud():
	if user_data:
		score_label.text = "Score: " + str(user_data.game_score)
		falls_label.text = "Falls: " + str(user_data.game_falls)
		vanquishes_label.text = "Vanquishes: " + str(user_data.game_vanquishes)
		level_label.text = "Level: " + str(user_data.game_level)
