extends Node

@export var api_id: String
@export var api_key: String

var http_request: HTTPRequest
var url = "https://www.killgorack.com/PX4/api.php"

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))

func send_data_to_server():
	var post_data = {
		"user_id": UserData.user_id,
		"username": UserData.username,
		"user_key": UserData.user_key,
		"freshness": UserData.freshness,
		"user_level": UserData.user_level,
		"game_score": UserData.game_score,
		"game_falls": UserData.game_falls,
		"game_vanquishes": UserData.game_vanquishes,
		"game_level": UserData.game_level,
		"function": "setUserData",
		"formidentifier": "alacarte\\game\\gameAPI"
	}
	var api_params = {
		"ap": "game",
		"cn": "hme",
		"vc": Creds.apiKEY,
		"api": "json",
		"apikeyid": Creds.apiID
	}
	var post_data_encoded = encode_dict_string(post_data)
	var full_url = url + "?" + encode_dict_string(api_params)
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	http_request.request(full_url, headers, HTTPClient.METHOD_POST, post_data_encoded)

func _on_request_completed(_result, _response_code, _headers, _body):
	var main_menu = get_tree().get_root().get_node("MainMenu")
	if main_menu:
		var load_group = main_menu.get_node_or_null("LoadGroup")
		if load_group and load_group.has_method("populate_user_info"):
			load_group.call("populate_user_info")
	UserData.calculate_level()


func encode_dict_string(data: Dictionary) -> String:
	var query_string = []
	for key in data.keys():
		var encoded_key = String(key).uri_encode()
		var encoded_value = str(data[key]).uri_encode()
		query_string.append(encoded_key + "=" + encoded_value)
	return String("&").join(query_string)
