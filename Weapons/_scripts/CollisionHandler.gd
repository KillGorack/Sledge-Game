extends RigidBody3D

@onready var raycast: RayCast3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
var weapon_settings: WeaponSettings
var current_position: Vector3
var current_direction: Vector3
var collision_point: Vector3
var collision_normal: Vector3
var collided_object: Object
var collided_layer: int = -1
var max_distance: float
var distance_traveled: float = 0.0
var RicochetCount: int = 0
var target_beacon: Node3D
var ignored_objects: Array = []
var guidedTarget: Node
var exclusions = []
var sf :float = 1





func _ready():
	current_direction = -global_transform.basis.z.normalized()
	current_position = global_transform.origin
	look_at(global_transform.origin + current_direction, Vector3.UP)
	linear_velocity = current_direction * weapon_settings.projectile_speed
	angular_velocity = current_direction * weapon_settings.projectile_spin
	if self is RigidBody3D:
		self.linear_velocity = linear_velocity
		self.angular_velocity = angular_velocity
	if weapon_settings.targeting_system == true:
		guidedTarget = Utilities.select_target(
			global_transform.origin,
			-global_transform.basis.z,
			weapon_settings.target_system_scan_radius, 
			15, 
			weapon_settings.target_system_group, 
			weapon_settings.targeting_system_require_marker)





func _physics_process(delta: float) -> void:
	var distance_this_frame = linear_velocity.length() * delta
	distance_traveled += distance_this_frame
	if distance_traveled >= max_distance:
		destroy_self()
	if weapon_settings.targeting_system == true:
		handleGuided(delta)
	if global_transform.origin.y < -25:
		destroy_self()





func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		collided_object = collider
		if collider:
			collided_layer = collider.collision_layer
			if raycast and raycast.is_colliding():
				collision_point = raycast.get_collision_point()
				collision_normal = raycast.get_collision_normal()
			else:
				collision_point = state.get_contact_local_position(i)
				collision_normal = state.get_contact_local_normal(i)
			handleCollision()
			break 
	if weapon_settings.use_gravity == false:
		linear_velocity = linear_velocity.normalized() * weapon_settings.projectile_speed





func set_weapon_settings(settings: WeaponSettings):
	weapon_settings = settings
	max_distance = weapon_settings.projectile_range
	if weapon_settings.mass == 0:
		weapon_settings.mass = 0.001
	self.mass = weapon_settings.mass
	if weapon_settings.use_gravity:
		self.gravity_scale = 1
	else:
		self.gravity_scale = 0
	collision_layer = 0
	collision_mask = 0
	self.set_collision_layer_value(weapon_settings.layer, true)
	for mask in weapon_settings.layer_mask:
		self.set_collision_mask_value(mask, true)
	sf = weapon_settings.sizing_scale
	self.scale = Vector3(sf, sf, sf)













func handleCollision():
	
	var destroy = true
	var result = []
		
	if (weapon_settings.explosive_force > 0 and weapon_settings.explosive_force_distance > 0) or weapon_settings.unfreeze == true:
		result = Utilities.collect_bodies(
			get_world_3d().direct_space_state, 
			global_transform.origin, 
			weapon_settings.body_collection_max, 
			weapon_settings.explosive_force_distance, 
			weapon_settings.target_system_group)
			
	if weapon_settings.unfreeze == true:
		unfreeze_targets(result)
		
	if weapon_settings.freeze_timer > 0:
		freeze_target()
			
	if weapon_settings.hit_points > 0:
		applyDirectDamage(weapon_settings.hit_points)
		
	if weapon_settings.projectile_force > 0:
		applyForce(weapon_settings.projectile_force)

	if weapon_settings.projectile_ricochet_count > 0:
		destroy = handleRicochet()
		
	if weapon_settings.projectile_pierce_count > 0:
		destroy = handlePierce()

	if weapon_settings.explosive_force > 0 and weapon_settings.explosive_force_distance > 0:
		applyAOEDamage(result)
		applyExplosiveForces(result)

	if weapon_settings.bounce_count > 0:
		destroy = handleBounce()

	setHitScene()
	create_bullet_hole()
	if destroy == true:
		destroy_self()





func unfreeze_targets(result):
	if weapon_settings.body_collection_max > 0 and weapon_settings.explosive_force_distance > 0:
		for item in result:
			var body = item.collider
			if body and is_instance_valid(body):
				if body != self:
					if body.has_method("setFreezeState"):
						body.call("setFreezeState", false)
						


func freeze_target():
	if collided_object and collided_object.has_method("setFreezeState"):
		var existing_timer = collided_object.get_node_or_null("FreezeTimer")
		if existing_timer:
			existing_timer.wait_time += weapon_settings.freeze_timer
			if not existing_timer.is_stopped():
				existing_timer.start()
		else:
			var timer = Timer.new()
			timer.name = "FreezeTimer"
			timer.wait_time = weapon_settings.freeze_timer
			timer.one_shot = true
			collided_object.add_child(timer)
			timer.timeout.connect(Callable(collided_object, "setFreezeState").bind(false))
			collided_object.call("setFreezeState", true)
			timer.start()





func applyDirectDamage(damage, target = null) -> void:
	var parental_object = target if target != null else collided_object
	if parental_object.has_method("apply_damage"):
		parental_object.apply_damage(damage)





func applyAOEDamage(result):
	for item in result:
		var body = item.collider
		if body != self:
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			if distance < weapon_settings.explosive_force_distance:
				var damage = weapon_settings.hit_points * (1.0 - (distance / weapon_settings.explosive_force_distance))
				if body.has_method("apply_damage"):
					body.apply_damage(damage)





func applyForce(force: float, target: Object = null, direction: Vector3 = Vector3.ZERO):
	var force_target = target if target != null else collided_object
	var force_direction = direction if not direction.is_zero_approx() else current_direction.normalized()
	if Input.is_action_pressed("Reverso") and weapon_settings.bi_directional:
		force_direction = -force_direction
	if force_target != null and force_target:
		if force_target.has_method("apply_directional_force"):
			force_target.apply_directional_force(force * force_direction)





func applyExplosiveForces(result):
	for item in result:
		var body = item.collider
		if body != self and body is RigidBody3D:
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			if distance < weapon_settings.explosive_force_distance:
				var force_strength = weapon_settings.explosive_force * (1.0 - (distance / weapon_settings.explosive_force_distance))
				var direction = (body.global_transform.origin - global_transform.origin).normalized()
				applyForce(force_strength, body, direction)





func handleRicochet():
	RicochetCount += 1
	if RicochetCount <= weapon_settings.projectile_ricochet_count:
		play_hit_sound()
		var reflect_direction = current_direction.bounce(collision_normal).normalized()
		current_direction = reflect_direction
		linear_velocity = reflect_direction * weapon_settings.projectile_speed
		global_transform.origin += reflect_direction * 0.5
		angular_velocity = current_direction * weapon_settings.projectile_spin
		look_at(global_transform.origin + reflect_direction, Vector3.UP)
		return false
	else:
		return true





func handlePierce() -> bool:
	if collided_layer == 2:
		return true
	if RicochetCount <= weapon_settings.projectile_pierce_count and collided_object not in ignored_objects:
		RicochetCount += 1
		ignored_objects.append(collided_object)
		global_transform.origin += current_direction.normalized() * 0.1
		look_at(global_transform.origin + current_direction, Vector3.UP)
		linear_velocity = current_direction.normalized() * weapon_settings.projectile_speed
		angular_velocity = Vector3.ZERO
		return false
	else:
		return true





func handleBounce():
	var bodies = Utilities.collect_bodies(
		get_world_3d().direct_space_state, 
		global_transform.origin, 
		weapon_settings.body_collection_max, 
		weapon_settings.target_system_scan_radius, 
		weapon_settings.target_system_group)
	if bodies.size() > 0 and RicochetCount <= weapon_settings.bounce_count:
		RicochetCount += 1 
		for item in bodies:
			var body = item.collider
			var direction = (body.global_transform.origin - global_transform.origin).normalized()
			linear_velocity = direction * weapon_settings.projectile_speed
			return false
		return true
	else:
		return true





func play_hit_sound() -> void:
	if weapon_settings.hit_sound:
		Utilities.play_sound(weapon_settings.hit_sound, global_transform.origin)





func selectTarget(radius: float, max_angle: float) -> void:
	var target_beacons = get_tree().get_nodes_in_group("Target_Beacon")
	if target_beacons.size() > 0:
		guidedTarget = target_beacons[0]
		return
	if weapon_settings.targeting_system_require_marker == false:
		var min_bound = global_position - Vector3(radius, radius, radius)
		var max_bound = global_position + Vector3(radius, radius, radius)
		var max_angle_rad = deg_to_rad(max_angle)
		for body in get_tree().get_nodes_in_group(weapon_settings.target_system_group):
			if not is_instance_valid(body):
				continue
			var pos = body.global_position
			if pos.x >= min_bound.x and pos.x <= max_bound.x and pos.y >= min_bound.y and pos.y <= max_bound.y and pos.z >= min_bound.z and pos.z <= max_bound.z:
				var to_target = (pos - global_position).normalized()
				if abs(to_target.angle_to(-global_transform.basis.z)) <= max_angle_rad:
					guidedTarget = body
					return





func handleGuided(delta):
	if not weapon_settings.targeting_system:
		return
	if guidedTarget and is_instance_valid(guidedTarget): 
		guide_to_target(delta)
		return





func guide_to_target(delta: float):
	if guidedTarget and is_instance_valid(guidedTarget):
		var direction_to_target = (guidedTarget.global_transform.origin - global_transform.origin).normalized()
		var missile_forward = -global_transform.basis.z
		var rotation_axis = missile_forward.cross(direction_to_target)
		if rotation_axis.length() == 0:
			rotation_axis = Vector3.UP
		else:
			rotation_axis = rotation_axis.normalized()
		var rotation_delta = Quaternion(rotation_axis, missile_forward.angle_to(direction_to_target) * weapon_settings.target_rotation_speed * delta).normalized()
		global_transform.basis = (Basis(rotation_delta) * global_transform.basis).orthonormalized()
		linear_velocity = -global_transform.basis.z * weapon_settings.projectile_speed





func create_bullet_hole():
	if weapon_settings.bullet_hole_prefab and collided_layer == 2:
		var bullet_hole_instance = weapon_settings.bullet_hole_prefab.instantiate()
		if get_parent():
			get_parent().add_child(bullet_hole_instance)
			var offset_position = collision_point + collision_normal * 0.01
			bullet_hole_instance.global_transform.origin = offset_position
			var up_vector = Vector3.UP
			if collision_normal.dot(up_vector) > 0.999:
				up_vector = Vector3.RIGHT
			var direction = (offset_position + collision_normal) - offset_position
			if not direction.is_zero_approx() and not up_vector.cross(direction).is_zero_approx():
				bullet_hole_instance.look_at_from_position(offset_position, offset_position + collision_normal, up_vector)





func setHitScene():
	play_hit_sound()
	if weapon_settings.explosion_prefab:
		var explosion_instance = weapon_settings.explosion_prefab.instantiate()
		get_parent().add_child(explosion_instance)
		explosion_instance.transform = global_transform





func destroy_self():
	setHitScene()
	await get_tree().create_timer(weapon_settings.projectile_destruction_delay).timeout
	queue_free()
