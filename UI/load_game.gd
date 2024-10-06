extends TextureRect

var levels : Array = []
var levels_dropdown : ItemList
var crafts : Array = []
var crafts_dropdown : ItemList

const LEVELS_PATH = "res://Levels/"
const CRAFTS_PATH = "res://Crafts/"

@onready var userInfo_label = get_parent().get_node("UserInfo")

func _ready():
	levels_dropdown = $Levels
	crafts_dropdown = $Crafts

func load_levels():
	var dir = DirAccess.open(LEVELS_PATH)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				var level_path = LEVELS_PATH + folder_name + "/" + folder_name + ".tscn"
				if ResourceLoader.exists(level_path):
					levels.append(level_path)
			folder_name = dir.get_next()
		dir.list_dir_end()


func load_crafts():
	var dir = DirAccess.open(CRAFTS_PATH)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				var craft_path = CRAFTS_PATH + folder_name + "/" + folder_name + ".tscn"
				if ResourceLoader.exists(craft_path):
					crafts.append(craft_path)
			folder_name = dir.get_next()
		dir.list_dir_end()


func populate_item_lists():
	levels_dropdown.clear()
	crafts_dropdown.clear()
	for level in levels:
		levels_dropdown.add_item(level.get_file().get_basename())
	for craft in crafts:
		crafts_dropdown.add_item(craft.get_file().get_basename())
	populateUserInfo()


func populateUserInfo():
	var usrTxt = ""
	usrTxt = UserData.username + ", " + "Level: " + str(UserData.game_level) + "\n"
	usrTxt += "Score: " + str(UserData.game_score) + "\n"
	usrTxt += "Vanquishes: " + str(UserData.game_vanquishes)+ ", " + "Falls: " + str(UserData.game_falls) 
	userInfo_label.text = usrTxt
	

func load_all():
	load_levels()
	load_crafts()
	populate_item_lists()
