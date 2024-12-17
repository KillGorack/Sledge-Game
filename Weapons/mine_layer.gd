extends Node3D

@export var mine_settings_array: Array[Resource] = []
@export var lbl_mines: Label
@onready var raycast = $MineCast
var current_mine_index = 0
var icon_mine: TextureRect
var current_mine_settings: Resource
var mine_lay_timer: float = 0.0

func _ready() -> void:
	if mine_settings_array.size() > 0:
		current_mine_settings = mine_settings_array[current_mine_index]
	icon_mine = get_node("../HUD/MineIcon")
	update_mine_label()

func _physics_process(delta: float) -> void:
	if mine_lay_timer > 0:
		mine_lay_timer -= delta
	if Input.is_action_just_pressed("mine_change"):
		change_mine()
	if Input.is_action_just_pressed("lay_mine") and current_mine_settings.count_actual > 0 and mine_lay_timer <= 0:
		lay_mine()

func lay_mine():
	if raycast.is_colliding() and can_lay_mine():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		if collider.is_in_group("Driveable"):
			var mine_scene = current_mine_settings.mine_prefab
			var mine_instance = mine_scene.instantiate()
			get_parent().get_parent().add_child(mine_instance)
			mine_instance.global_transform.origin = collision_point
			var up_vector = collision_normal.normalized()
			var transform = mine_instance.global_transform
			transform.basis.y = up_vector
			transform.basis.x = Vector3(1, 0, 0).cross(up_vector).normalized()
			transform.basis.z = up_vector.cross(transform.basis.x).normalized()
			mine_instance.global_transform = transform
			if current_mine_settings.lay_sound:
				var audio_player = AudioStreamPlayer.new()
				audio_player.stream = current_mine_settings.lay_sound
				get_parent().get_parent().add_child(audio_player)
				audio_player.play()
			current_mine_settings.count_actual -= 1
			if current_mine_settings.count_actual < 0:
				current_mine_settings.count_actual = 0
			update_mine_label()
			if mine_instance.has_method("set_settings"):
				mine_instance.set_settings(current_mine_settings)
			mine_lay_timer = current_mine_settings.cool_down

func can_lay_mine() -> bool:
	var existing_mines = 0
	for child in get_parent().get_parent().get_children():
		if child.is_in_group("Mine"):
			if child.has_method("get_settings") and child.get_settings().mine_name == current_mine_settings.mine_name:
				existing_mines += 1
	return existing_mines < current_mine_settings.max_count

func change_mine():
	current_mine_index += 1
	if current_mine_index >= mine_settings_array.size():
		current_mine_index = 0
	current_mine_settings = mine_settings_array[current_mine_index]
	update_mine_label()

func update_mine_label():
	icon_mine.texture = current_mine_settings.mine_icon
	lbl_mines.text = str(current_mine_settings.count_actual) + " / " + str(current_mine_settings.count_capacity)
