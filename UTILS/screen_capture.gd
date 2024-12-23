extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_action_pressed("take_screen_capture"):
			take_screen_capture()

func take_screen_capture():
	var base_dir = OS.get_executable_path().get_base_dir()
	var screenies_dir = base_dir + "/Screenies"
	var dir = DirAccess.open(screenies_dir)
	if dir == null:
		dir = DirAccess.open(base_dir)
		if not dir.make_dir_recursive(screenies_dir):
			push_error("Failed to create directory: " + screenies_dir)
			return
	var game_name = ProjectSettings.get_setting("application/config/name", "Game")
	var now = Time.get_time_dict_from_system()
	var nowDate = Time.get_date_dict_from_system()
	var datetime_string = "%04d%02d%02d%02d%02d%02d" % [
		nowDate.year, nowDate.month, nowDate.day, now.hour, now.minute, now.second
	]
	var filename = "%s Screen Capture %s.png" % [game_name, datetime_string]
	var file_path = "%s/%s" % [screenies_dir, filename]
	var image = get_viewport().get_texture().get_image()
	if image:
		image.save_png(file_path)
		print("Screenshot saved to:", file_path)
	else:
		push_error("Failed to capture screenshot.")
