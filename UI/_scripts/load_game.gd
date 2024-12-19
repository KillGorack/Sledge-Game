extends TextureRect

const LEVELS_PATH = "res://Levels/"
const CRAFTS_PATH = "res://Crafts/"

var levels: Array = []
var crafts: Array = []

@onready var levels_dropdown: ItemList = $Levels as ItemList
@onready var crafts_dropdown: ItemList = $Crafts as ItemList
@onready var btn_load = $btn_load as Button
@onready var userInfo_label = get_parent().get_node("UserInfo")
@onready var music_player

@export var NPC: PackedScene

var current_level_instance: Node = null
var current_craft_instance: Node = null
var npc_instances: Array = []

func _ready() -> void:
	music_player = get_parent().get_node("AmbientMusic") as AudioStreamPlayer
	btn_load.connect("pressed", Callable(self, "_on_load_button_pressed"))





func _on_load_button_pressed() -> void:
	var selected_level_index = levels_dropdown.get_selected_items()[0]
	var selected_craft_index = crafts_dropdown.get_selected_items()[0]
	if selected_level_index == -1 or selected_craft_index == -1:
		print("Please select both a level and a craft.")
		return
	var selected_level = levels[selected_level_index]
	var selected_craft = crafts[selected_craft_index]
	load_selected_world_and_craft(selected_level, selected_craft)





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
	if levels_dropdown.get_item_count() > 0:
		levels_dropdown.select(0)
	for craft in crafts:
		crafts_dropdown.add_item(craft.get_file().get_basename())
	if crafts_dropdown.get_item_count() > 0:
		crafts_dropdown.select(0)
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
	
	
	
	
	
func load_selected_world_and_craft(level_path: String, craft_path: String) -> void:
	unload_current_world_and_craft()
	music_player.stop()
	get_parent().hide()
	var level_resource = load(level_path)
	var craft_resource = load(craft_path)
	if not level_resource or not craft_resource:
		return
	var level_scene = level_resource as PackedScene
	var craft_scene = craft_resource as PackedScene
	if not level_scene or not craft_scene:
		return
	current_level_instance = level_scene.instantiate()
	current_craft_instance = craft_scene.instantiate()
	get_parent().get_parent().add_child(current_level_instance)
	get_parent().get_parent().add_child(current_craft_instance)
	spawn_npcs(current_level_instance)
	var node_3d = current_level_instance.get_node("PlayerSpawn") as Node3D
	if node_3d:
		current_craft_instance.global_transform = node_3d.global_transform




func spawn_npcs(level_instance: Node) -> void:
	if !level_instance.has_node("NPC_SpawnPoints"):
		return
	var npc_spawn_parent = level_instance.get_node("NPC_SpawnPoints")
	if not npc_spawn_parent:
		return
	for spawn_point in npc_spawn_parent.get_children():
		if spawn_point.name.begins_with("NPC_") and NPC:
			var npc_instance = NPC.instantiate()
			npc_instance.global_transform = spawn_point.global_transform
			get_parent().get_parent().add_child(npc_instance)
			npc_instances.append(npc_instance)
			
			
			

			
func unload_current_world_and_craft() -> void:
	if current_level_instance:
		current_level_instance.queue_free()
		current_level_instance = null
	if current_craft_instance:
		current_craft_instance.queue_free()
		current_craft_instance = null
	junkRemover()
		
		
		
func junkRemover() -> void:
	for node in get_tree().get_nodes_in_group("Projectile"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("Creative"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("Mine"):
		node.queue_free()
		

func playerDestroyed():
		UserData.game_falls += 1
		UserData.calculate_level()
		UserDataApi.send_data_to_server()
		unload_current_world_and_craft()
		get_parent().show()
		music_player.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MainMenu"):
		
		UserDataApi.send_data_to_server()
		unload_current_world_and_craft()
		get_parent().show()
		music_player.play()
