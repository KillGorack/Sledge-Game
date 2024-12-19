extends Node

var emit_id: int
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
const MAX_LEVEL: int = 100
const MAX_VANQUISHES: int = 100000

signal data_updated(category: String)

func populate_user_data(data: Dictionary):
	emit_id = data_updated.get_object_id()
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

func getUserData() -> Dictionary:
	return {
		"game_score": game_score,
		"game_falls": game_falls,
		"game_vanquishes": game_vanquishes,
		"game_level": game_level
	}

func getJSON() -> String:
	var data_dict = {
		"user_id": user_id,
		"username": username,
		"user_key": user_key,
		"freshness": freshness,
		"user_level": user_level,
		"game_score": game_score,
		"game_falls": game_falls,
		"game_vanquishes": game_vanquishes,
		"game_level": game_level,
	}
	var jsonString = JSON.stringify(data_dict)
	return jsonString
	
func calculate_level():
	if game_vanquishes <= 0:
		return 1
	var progress_ratio = float(game_vanquishes) / MAX_VANQUISHES
	game_level = lerp(1, MAX_LEVEL, progress_ratio ** 0.5)
	game_score = 250 * game_vanquishes
