extends Node

var http_request: HTTPRequest
var url = "https://www.killgorack.com/PX4/api.php"
var api_params: Dictionary = {}
var function_complete: String = ""
var creative_settings: Dictionary = {}

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("save_user_space"):
		save_user_space()





func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	api_params = {
		"ap": "game",
		"cn": "hme",
		"vc": Creds.apiKEY,
		"api": "json",
		"apikeyid": Creds.apiID
	}





func send_data_to_server():
	function_complete = "send_data_to_server"
	UserData.calculate_level()
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
	var post_data_encoded = encode_dict_string(post_data)
	var full_url = url + "?" + encode_dict_string(api_params)
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	http_request.request(full_url, headers, HTTPClient.METHOD_POST, post_data_encoded)





func _on_request_completed(_result, response_code, _headers, body):
	if function_complete == "save_user_space":
		pass
	elif function_complete == "get_user_space":
		if response_code == 200:
			var json_parser = JSON.new()
			var parse_result = json_parser.parse(body.get_string_from_utf8())
			if parse_result == OK:
				var data = json_parser.get_data()
				if data.has("buildData"):
					for item in data["buildData"]:
						var SceneName = item.get("name", "Unknown")
						var location = item.get("location", {})
						var orientation = item.get("orientation", {})
						var CreativeLocation: Vector3 = Vector3(location.get("x", 0), location.get("y", 0), location.get("z", 0))
						var CreativeOrientation: Vector3 = Vector3(orientation.get("x", 0), orientation.get("y", 0), orientation.get("z", 0))
						place_creative(SceneName, CreativeLocation, CreativeOrientation)
	elif function_complete == "send_data_to_server":
		var main_menu = get_tree().get_root().get_node("MainMenu")
		if main_menu:
			var load_group = main_menu.get_node_or_null("LoadGroup")
			if load_group and load_group.has_method("populate_user_info"):
				load_group.call("populate_user_info")
		UserData.calculate_level()





func save_user_space():
	function_complete = "save_user_space"
	var root_node = get_tree().root
	if root_node == null:
		return
	var node_data = []
	for child in root_node.get_children():
		if child.is_in_group("Creative"):
			
			
			var location = child.global_transform.origin
			var orientation = child.global_transform.basis.get_euler()
			
			var rounded_orientation = {
				"x": round_to_nearest_90(orientation.x),
				"y": round_to_nearest_90(orientation.y),
				"z": round_to_nearest_90(orientation.z)
			}
			var attached_name = ""
			if child.creative_settings.Name:
				attached_name = child.creative_settings.Name
			var node_info = {
				"name": attached_name,
				"location": {
					"x": round(location.x * 2) / 2,  # Round position to nearest 0.5 unit
					"y": round(location.y * 2) / 2,  # Round position to nearest 0.5 unit
					"z": round(location.z * 2) / 2   # Round position to nearest 0.5 unit
				},
				"orientation": rounded_orientation  # Use rounded Euler angles for orientation
			}
			node_data.append(node_info)
	var json_string = JSON.stringify(node_data, "\t")
	var post_data = {
		"user_id": UserData.user_id,
		"username": UserData.username,
		"user_key": UserData.user_key,
		"freshness": UserData.freshness,
		"function": "updateUserSpace",
		"formidentifier": "alacarte\\game\\gameAPI",
		"jsonData" : json_string
	}
	var post_data_encoded = encode_dict_string(post_data)
	var full_url = url + "?" + encode_dict_string(api_params)
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	http_request.request(full_url, headers, HTTPClient.METHOD_POST, post_data_encoded)




func get_user_space(creatives_array):
	creative_settings = populate_creatives(creatives_array)
	function_complete = "get_user_space"
	var post_data = {
		"user_id": UserData.user_id,
		"username": UserData.username,
		"user_key": UserData.user_key,
		"freshness": UserData.freshness,
		"function": "getUserSpace",
		"formidentifier": "alacarte\\game\\gameAPI"
	}
	var post_data_encoded = encode_dict_string(post_data)
	var full_url = url + "?" + encode_dict_string(api_params)
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	http_request.request(full_url, headers, HTTPClient.METHOD_POST, post_data_encoded)
	
	



func populate_creatives(creatives_array: Array) -> Dictionary:
	var creatives_dict: Dictionary = {}
	for creative_resource in creatives_array:
		if creative_resource is CreativeSettings:
			var creative_name = creative_resource.Name
			creatives_dict[creative_name] = creative_resource
	return creatives_dict


	


func encode_dict_string(data: Dictionary) -> String:
	var query_string = []
	for key in data.keys():
		var encoded_key = String(key).uri_encode()
		var encoded_value = str(data[key]).uri_encode()
		query_string.append(encoded_key + "=" + encoded_value)
	return String("&").join(query_string)
	
	
func place_creative(n, l, o):
	var creative_resource = creative_settings.get(n, null)
	if creative_resource:
		var scene_to_spawn = creative_resource.Scene
		if scene_to_spawn:
			var new_creative_instance = scene_to_spawn.instantiate()
			get_tree().root.add_child(new_creative_instance)
			new_creative_instance.global_transform.origin = l
			new_creative_instance.set_settings(creative_resource)
			new_creative_instance.global_transform.basis = Basis().rotated(Vector3(1, 0, 0), o.x).rotated(Vector3(0, 1, 0), o.y).rotated(Vector3(0, 0, 1), o.z)
			
func round_to_nearest_90(angle: float) -> float:
	return round(angle / deg_to_rad(90.0)) * deg_to_rad(90.0)
