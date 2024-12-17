extends Node

const MAX_PLAYERS = 10
var audio_pool: Array = []

func _ready():
	for i in range(MAX_PLAYERS):
		var player = AudioStreamPlayer3D.new()
		player.name = "AudioStreamPlayer3D_{}".format([i])
		player.finished.connect(_on_audio_finished.bind(player))
		add_child(player)
		audio_pool.append(player)





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
