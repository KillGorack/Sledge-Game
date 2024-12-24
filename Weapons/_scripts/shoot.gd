extends MeshInstance3D

@export var weapon_settings_array: Array[Resource] = []
@export var target_scene: PackedScene
@export var power_node: Node3D
@export var reload_sound: AudioStream
@onready var camera: Camera3D = $Camera3D
@onready var raycast = $TargetCast


var current_weapon_index = 0
var shoot_timer = 0.0
var current_weapon_settings: Resource
var hud: CenterContainer
var rounds: Label
var item_name: Label
var icon_weapon: TextureRect
var this_node_enabled: bool = true

var is_shooting: bool = false



func _ready() -> void:
	if weapon_settings_array.size() > 0:
		current_weapon_settings = weapon_settings_array[current_weapon_index]
	hud = get_node("../../HUD/CrossHairs")
	icon_weapon = get_node("../../HUD/item_icon")
	rounds = get_node("../../HUD/lbl_item_count")
	item_name = get_node("../../HUD/lbl_item_name")
	update_weapon_label()





func _physics_process(delta):
		
	if Utilities.game_mode_index != 0:
		this_node_enabled = false
		return
	elif this_node_enabled == false:
		this_node_enabled = true
		update_weapon_label()
		
	if shoot_timer > 0:
		shoot_timer -= delta
	if Input.is_action_pressed("FireWeapon") and shoot_timer <= 0:
		shoot_projectile()
		if hud and hud.has_method("colorCrossHairs"):
			hud.colorCrossHairs("RED", current_weapon_settings.cool_down)
	if Input.is_action_just_pressed("weapon_change"):
		change_weapon()
	if Input.is_action_just_pressed("paintTarget"):
		place_target()
	if Input.is_action_just_pressed("display_tree"):
		Utilities.print_first_level_nodes()





func shoot_projectile():
	if is_shooting:
		return

	if current_weapon_settings:

		if power_node.getPower() < current_weapon_settings.power_consumption:
			return
		if current_weapon_settings.projectile_count_actual < current_weapon_settings.projectile_count and current_weapon_settings.projectile_count_capacity != 0:
			return

		is_shooting = true
		current_weapon_settings.projectile_count_actual -= current_weapon_settings.projectile_count
		play_launch_sound()

		if current_weapon_settings.power_consumption > 0:
			rounds.text = "Power"
		else:
			rounds.text = str(current_weapon_settings.projectile_count_actual) + " / " + str(current_weapon_settings.projectile_count_capacity)

		power_node.spendPower(current_weapon_settings.power_consumption)
		
		await get_tree().create_timer(current_weapon_settings.projectile_fire_delay).timeout
		var angle_step = 360.0 / current_weapon_settings.projectile_count
		var direction = camera.global_transform.basis.z.normalized()
		var right = camera.global_transform.basis.x.normalized()
		var up = camera.global_transform.basis.y.normalized()
		var projectile_scene = current_weapon_settings.projectile_prefab
		
		for i in range(current_weapon_settings.projectile_count):
			var angle = deg_to_rad(current_weapon_settings.projectile_start_angle + i * angle_step)
			var offset = (right * cos(angle) + up * sin(angle)) * current_weapon_settings.projectile_spacing
			var projectile_instance = projectile_scene.instantiate()
			if projectile_instance:
				if projectile_instance.has_method("set_weapon_settings"):
					projectile_instance.set_weapon_settings(current_weapon_settings)
					shoot_timer = current_weapon_settings.cool_down
				var spawn_transform = camera.global_transform
				spawn_transform.origin += offset + (direction * current_weapon_settings.launch_offset)
				projectile_instance.global_transform = spawn_transform
				var initial_velocity = direction * current_weapon_settings.projectile_speed
				projectile_instance.linear_velocity = initial_velocity
				get_tree().root.add_child(projectile_instance)
				get_parent().get_parent().apply_central_impulse(current_weapon_settings.projectile_recoil * direction)
		is_shooting = false



func reload_all_weapons():
	var ps: bool = false
	for weapon in weapon_settings_array:
		if weapon.projectile_count_capacity > weapon.projectile_count_actual:
			ps = true
		weapon.projectile_count_actual = weapon.projectile_count_capacity
	if Utilities.game_mode_index == 0:
		update_weapon_label()
	if reload_sound and ps:
		Utilities.play_sound(reload_sound, global_transform.origin)
	


func change_weapon():
	if is_shooting:
		return
	current_weapon_index += 1
	if current_weapon_index >= weapon_settings_array.size():
		current_weapon_index = 0
	current_weapon_settings = weapon_settings_array[current_weapon_index]
	update_weapon_label()





func update_weapon_label():
	icon_weapon.texture = current_weapon_settings.weapon_icon
	item_name.text = current_weapon_settings.weapon_name
	if current_weapon_settings.power_consumption > 0:
		rounds.text = "Power"
	else:
		rounds.text = str(current_weapon_settings.projectile_count_actual) + " / " + str(current_weapon_settings.projectile_count_capacity)





func play_launch_sound() -> void:
	if current_weapon_settings.launch_sound:
		var audio_player = AudioStreamPlayer3D.new()
		add_child(audio_player)
		audio_player.stream = current_weapon_settings.launch_sound
		audio_player.transform.origin = transform.origin
		audio_player.play()
		Utilities.GarbageCollection(audio_player, 5.0)
		
		
		
		
		
func place_target():
	if is_shooting:
		return
	var existing_targets = get_tree().get_nodes_in_group("Target_Beacon")
	if existing_targets.size() > 0:
		return
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_object = raycast.get_collider()
		if target_scene:
			var target_instance = target_scene.instantiate()
			collision_object.add_child(target_instance)
			if collision_object is Node:
				target_instance.global_transform.origin = collision_point
