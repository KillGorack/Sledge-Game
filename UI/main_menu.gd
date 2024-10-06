extends Control

@onready var http_request = $HTTPRequest
@onready var username_field = $LoginGroup/txt_username
@onready var password_field = $LoginGroup/txt_password
@onready var login_button = $LoginGroup/btn_login
@onready var register_button = $LoginGroup/btn_register
@onready var quit_button = $btn_quit
@onready var welcome_label = $WelcomeLabel
@onready var login_group = $LoginGroup
@onready var load_group = $LoadGroup
@onready var background = $Background
@onready var login_timer = Timer.new()

var api_keyFile = "res://UI/APIKeys/api_key.txt"
var api_url = "https://www.killgorack.com/PX4/api.php"
var api_credentials = {
	"API_ID": "",
	"API_KEY": ""
}

var backdrop_paths: Array = []

var login_attempts: int = 0
var max_attempts: int = 5
var cooldown_seconds: int = 30
var is_cooldown: bool = false





func _ready():
	username_field.grab_focus()
	quit_button.connect("pressed", Callable(self, "_on_close"))
	login_button.connect("pressed", Callable(self, "_on_login"))
	register_button.connect("pressed", Callable(self, "_on_register"))
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	add_child(login_timer)
	login_timer.connect("timeout", Callable(self, "_on_cooldown_finished"))
	login_timer.one_shot = true
	load_backdrop_paths("res://UI/backdrops/")
	set_random_backdrop()
	login_group.show()
	load_group.hide()





func load_api_keys(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return false
	for i in range(2):
		var line = file.get_line().strip_edges()
		var key_value = line.split("=")
		if key_value.size() == 2:
			api_credentials[key_value[0].strip_edges()] = key_value[1].strip_edges()
	file.close()
	return true



		
		
		
func _on_register():
	var url = "https://www.killgorack.com/PX4/index.php?ap=hme&ala=register"
	OS.shell_open(url)





func load_backdrop_paths(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir != null:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				backdrop_paths.append(folder_path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()





func set_random_backdrop():
	if backdrop_paths.size() > 0:
		var random_index = randi() % backdrop_paths.size()
		var random_backdrop = backdrop_paths[random_index]
		var texture = load(random_backdrop)
		background.texture = texture





func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_login()





func _on_close():
	get_tree().quit()





func _on_login():
	load_api_keys(api_keyFile)
	if is_cooldown:
		welcome_label.text = "Please wait 30 seconds before trying again."
		return
	var username = username_field.text
	var password = password_field.text
	if username == "" or password == "":
		welcome_label.text = "Please enter both username and password."
		return
	login_attempts += 1
	if login_attempts > max_attempts:
		is_cooldown = true
		resetForm()
		username_field.editable = false
		password_field.editable = false
		login_button.disabled = true
		welcome_label.text = "Too many attempts. Please wait 30 seconds before trying again."
		login_timer.start(cooldown_seconds)
		return
	var post_data = {
		"function" : "authenticate",
		"userName": username,
		"password": password,
		"formidentifier": "alacarte\\sledge\\unityAuth"
	}
	var api_params = {
		"ap": "sledge",
		"apikeyid": api_credentials["API_ID"],
		"api": "json",
		"vc": api_credentials["API_KEY"]
	}
	var post_data_encoded = encode_dict_string(post_data)
	var full_url = api_url + "?" + encode_dict_string(api_params)
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	http_request.request(full_url, headers, HTTPClient.METHOD_POST, post_data_encoded)





func encode_dict_string(data: Dictionary) -> String:
	var query_string = []
	for key in data.keys():
		var encoded_key = String(key).uri_encode()
		var encoded_value = str(data[key]).uri_encode()
		query_string.append(encoded_key + "=" + encoded_value)
	return String(",").join(query_string).replace(",", "&")





func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var user_data = json_parser.get_data()
			if user_data.data.access == "granted":
				login_attempts = 0
				is_cooldown = false
				UserData.populate_user_data(user_data.data)
				welcome_label.text = ""
				login_group.hide()
				load_group.show()
				var load_game_instance = get_node("LoadGroup")
				load_game_instance.load_all()
			else:
				resetForm()
				welcome_label.text = "Login NOT successful, please try again!"
		else:
			welcome_label.text = "Server error. Please try again later."







func resetForm():
	username_field.text = ""
	password_field.text = ""
	username_field.grab_focus()





func _on_cooldown_finished():
	is_cooldown = false
	username_field.editable = true
	password_field.editable = true
	login_button.disabled = false
	welcome_label.text = "You can try logging in again now."
