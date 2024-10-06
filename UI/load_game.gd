extends TextureRect

const LEVELS_PATH = "res://Levels/"
const CRAFTS_PATH = "res://Crafts/"

var levels: Array = []
var crafts: Array = []

@onready var levels_dropdown: ItemList = $Levels as ItemList
@onready var crafts_dropdown: ItemList = $Crafts as ItemList
@onready var userInfo_label = get_parent().get_node("UserInfo")

func _ready() -> void:
	pass
	#load_all()





func load_levels() -> void:
	load_resources(LEVELS_PATH, levels)





func load_crafts() -> void:
	load_resources(CRAFTS_PATH, crafts)





func load_resources(path: String, resource_array: Array) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				var resource_path = path + folder_name + "/" + folder_name + ".tscn"
				if ResourceLoader.exists(resource_path):
					resource_array.append(resource_path)
			folder_name = dir.get_next()
		dir.list_dir_end()





func populate_item_lists() -> void:
	levels_dropdown.clear()
	crafts_dropdown.clear()
	for level in levels:
		levels_dropdown.add_item(level.get_file().get_basename())
	for craft in crafts:
		crafts_dropdown.add_item(craft.get_file().get_basename())
	populate_user_info()





func populate_user_info() -> void:
	var usrTxt = "%s, Level: %d\nScore: %d\nVanquishes: %d, Falls: %d" % [
		UserData.username,
		UserData.game_level,
		UserData.game_score,
		UserData.game_vanquishes,
		UserData.game_falls
	]
	userInfo_label.text = usrTxt





func load_all() -> void:
	load_levels()
	load_crafts()
	populate_item_lists()
