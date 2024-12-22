extends Node

const MAX_PLAYERS = 25
var audio_pool: Array = []
var game_modes: Array = ["Battle Mode", "Mine Mode", "Creative Mode"]
var game_mode_index: int = 0
var game_mode: String = game_modes[game_mode_index]


func _ready():
	randomize()
	for i in range(MAX_PLAYERS):
		var player = AudioStreamPlayer3D.new()
		player.name = "AudioStreamPlayer3D_{}".format([i])
		player.finished.connect(_on_audio_finished.bind(player))
		add_child(player)
		audio_pool.append(player)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("game_mode"):
		Utilities.toggle_game_mode()

func update_game_mode_label():
	var player_nodes = get_tree().get_nodes_in_group("Player")
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		var hud = player.get_node("HUD")
		var lbl_game_mode = hud.get_node("lbl_game_mode")
		lbl_game_mode.text = game_modes[game_mode_index]




func toggle_game_mode():
	game_mode_index += 1
	if game_mode_index > 2:
		game_mode_index = 0
	game_mode = game_modes[game_mode_index]
	update_game_mode_label()


func play_sound(audio_input: Variant, position: Vector3 = Vector3.ZERO):
	var stream = null
	if typeof(audio_input) == TYPE_STRING:
		stream = load(audio_input)
	elif audio_input is AudioStream:
		stream = audio_input
	else:
		return
	var player = get_free_player()
	if player:
		player.stream = stream
		player.global_transform.origin = position
		player.play()


func get_free_player() -> AudioStreamPlayer3D:
	for player in audio_pool:
		if !player.is_playing():
			return player
	return null


func _on_audio_finished(player: AudioStreamPlayer3D):
	if player:
		player.stream = null


func GarbageCollection(node: Node, delay: float) -> void:
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	node.add_child(timer)
	timer.connect("timeout", node.queue_free)
	timer.start()


func print_first_level_nodes() -> void:
	var root = get_tree().root
	print("Current First-Level Scene Nodes:")
	for child in root.get_children():
		print(child.name + " (" + child.get_class() + ")")
		for grandchild in child.get_children():
			print("    " + grandchild.name + " (" + grandchild.get_class() + ")")


func collect_bodies(space_state: PhysicsDirectSpaceState3D, origin: Vector3, n: int, dist: float, target_group: String) -> Array:
	var query = PhysicsShapeQueryParameters3D.new()
	query.transform = Transform3D(Basis(), origin)
	query.shape = SphereShape3D.new()
	query.shape.radius = dist
	var result = space_state.intersect_shape(query, n)
	var filtered_result = []
	for item in result:
		if item.collider.is_in_group(target_group):
			filtered_result.append(item)
	return filtered_result


func select_target(origin: Vector3, forward_direction: Vector3, radius: float, max_angle: float, target_group: String, targeting_system_require_marker: bool) -> Node:
	var target_beacons = get_tree().get_nodes_in_group("Target_Beacon")
	if target_beacons.size() > 0:
		return target_beacons[0]
	if not targeting_system_require_marker:
		var min_bound = origin - Vector3(radius, radius, radius)
		var max_bound = origin + Vector3(radius, radius, radius)
		var max_angle_rad = deg_to_rad(max_angle)
		var potential_targets = []
		for body in get_tree().get_nodes_in_group(target_group):
			if not is_instance_valid(body):
				continue
			var pos = body.global_position
			if pos.x >= min_bound.x and pos.x <= max_bound.x and pos.y >= min_bound.y and pos.y <= max_bound.y and pos.z >= min_bound.z and pos.z <= max_bound.z:
				var to_target = (pos - origin).normalized()
				if abs(to_target.angle_to(forward_direction)) <= max_angle_rad:
					potential_targets.append(body)
		if potential_targets.size() > 0:
			return potential_targets[randi() % potential_targets.size()]
	return null
