extends Node3D

@export var turret: MeshInstance3D
@export var barrel: MeshInstance3D
@export var projectile_scene: PackedScene
@export var shoot_cooldown: float = 1.0
@export var weapon_settings: Array[Resource] = []

var player: Node3D
var shoot_cast: RayCast3D
var rotation_speed: float = 5
var shoot_timer = 0.0


var current_weapon_settings: Resource

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	shoot_cast = barrel.get_node("ShootCast") if barrel.has_node("ShootCast") else null
	if shoot_cast == null:
		print("ShootCast node not found under barrel!")
	select_random_weapon_setting()
	
func select_random_weapon_setting():
	if weapon_settings.size() > 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		current_weapon_settings = weapon_settings[rng.randi_range(0, weapon_settings.size() - 1)]
	else:
		print("No weapon settings available!")


func _physics_process(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	if distance_to_player <= 10:
		var turret_target_rotation = turret.global_transform.looking_at(player.global_transform.origin, Vector3.UP).basis
		turret.global_transform.basis = turret.global_transform.basis.slerp(turret_target_rotation, rotation_speed * delta)
		turret.rotation.x = 0
		turret.rotation.z = 0
		var barrel_target_rotation = barrel.global_transform.looking_at(player.global_transform.origin, Vector3.UP).basis
		barrel.global_transform.basis = barrel.global_transform.basis.slerp(barrel_target_rotation, rotation_speed * delta)
		barrel.rotation.y = 0
		barrel.rotation.z = 0
		if shoot_cast and shoot_cast.is_colliding() and shoot_timer <= 0:
			var collider = shoot_cast.get_collider()
			if collider and collider.collision_layer == 1:
				shoot_projectile()
	else:
		reset_turret_and_barrel(delta)

func reset_turret_and_barrel(delta):
	turret.rotation_degrees.y = lerp(turret.rotation_degrees.y, 0.0, rotation_speed * delta)
	barrel.rotation_degrees.x = lerp(barrel.rotation_degrees.x, 0.0, rotation_speed * delta)

func shoot_projectile():
	if current_weapon_settings:
		var angle_step = 360.0 / current_weapon_settings.projectile_count
		for i in range(current_weapon_settings.projectile_count):
			var angle = deg_to_rad(current_weapon_settings.projectile_start_angle + i * angle_step)
			var direction = barrel.global_transform.basis.z.normalized()
			var right = barrel.global_transform.basis.x.normalized()
			var up = barrel.global_transform.basis.y.normalized()
			var offset = (right * cos(angle) + up * sin(angle)) * current_weapon_settings.projectile_spacing
			projectile_scene = current_weapon_settings.projectile_prefab
			var projectile_instance = projectile_scene.instantiate()
			if projectile_instance:
				if projectile_instance.has_method("set_weapon_settings"):
					projectile_instance.set_weapon_settings(current_weapon_settings)
					shoot_timer = current_weapon_settings.cool_down
				var spawn_transform = barrel.global_transform
				spawn_transform.origin += direction * -0.5 + offset
				projectile_instance.global_transform = spawn_transform
				var initial_velocity = direction * current_weapon_settings.projectile_speed
				projectile_instance.linear_velocity = initial_velocity
				get_tree().root.add_child(projectile_instance)
				get_parent().apply_central_impulse(current_weapon_settings.projectile_recoil * direction)
				play_launch_sound()

func play_launch_sound() -> void:
	pass
