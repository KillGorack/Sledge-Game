extends Node

var user_id: int
var username: String
var email: String
var enabled: bool
var user_key: String
var freshness: String
var user_level: int
var phone: String
var game_score: int
var game_falls: int
var game_vanquishes: int
var game_level: int
var access: String

signal data_updated(category: String)

func populate_user_data(data: Dictionary):
	user_id = data.get("ID", 0)
	username = data.get("usr_login", "")
	email = data.get("usr_email", "")
	enabled = data.get("usr_enable", 0) == 1
	user_key = data.get("usr_key", "")
	freshness = data.get("usr_freshness", "")
	user_level = data.get("usr_lvl", 0)
	phone = data.get("usr_phone", "")
	game_score = data.get("game_score", 0)
	game_falls = data.get("game_falls", 0)
	game_vanquishes = data.get("game_vanquishes", 0)
	game_level = data.get("game_level", 0)
	access = data.get("access", "")

func updateUserData(category: String, amount: int) -> void:
	match category:
		"Falls":
			game_falls = game_falls + amount
		"Vanquishes":
			game_vanquishes = game_vanquishes + amount
		_:
			pass
	emit_signal("data_updated")
