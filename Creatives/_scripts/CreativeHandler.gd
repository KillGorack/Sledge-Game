extends RigidBody3D

var creative_settings: CreativeSettings
var life_original: float = 1
var death_bit: bool = false
var original_friction: float = 1.0
var stop_forces = false
var freezeBit: bool = false
var default_values: Dictionary = {}

func _ready() -> void:
	if physics_material_override:
		original_friction = physics_material_override.friction
	default_values = {
		"Life": 100.0,
		"kenetic_threshold": 70.0,
		"Explosion_Scene": preload("res://Explosive/Explosions/Explosion_A/Explosion_A.tscn"),
		"Explosion_Sound": preload("res://Sounds/Weapons/Explosion.wav")
	}
	_set_life(default_values["Life"])





func set_settings(settings: CreativeSettings) -> void:
	creative_settings = settings.duplicate()
	life_original = settings.Life
	_set_life(life_original)





func _process(_delta: float) -> void:
	if global_transform.origin.y < -25:
		destroy_self()





func apply_damage(damage: float) -> void:
	var current_life = _get_life()
	current_life -= damage
	_set_life(current_life)
	if current_life <= 0:
		_handle_death()
	elif current_life <= _get_kinetic_threshold():
		_set_freeze_state(false)





func destroy_self() -> void:
	var explosion_scene = _get_explosion_scene()
	if explosion_scene:
		var instance = explosion_scene.instantiate()
		get_parent().add_child(instance)
		call_deferred("_set_instance_properties", instance)
		play_destruction_sound()
	queue_free()





func setFreezeState(bit: bool) -> void:
	sleeping = bit
	freeze = bit
	freezeBit = bit
	if not bit:
		var freeze_timer = get_node_or_null("FreezeTimer")
		if freeze_timer:
			freeze_timer.queue_free()





func setTempFreese(delay: float) -> void:
	_set_freeze_state(true)
	await get_tree().create_timer(delay).timeout
	_set_freeze_state(false)





func apply_directional_force(impulse: Vector3) -> void:
	stop_forces = true
	_set_friction(0)
	apply_central_impulse(impulse)
	await get_tree().create_timer(1.0).timeout
	_set_friction(original_friction)
	stop_forces = false





func _set_instance_properties(instance: Node) -> void:
	instance.global_transform.origin = global_transform.origin
	instance.scale = Vector3(5, 5, 5)





func _set_friction(value: float) -> void:
	if physics_material_override:
		physics_material_override.friction = value



func play_destruction_sound():
	if creative_settings:
		Utilities.play_sound(creative_settings.Explosion_Sound, transform.origin)
	else:
		Utilities.play_sound(default_values["Explosion_Sound"], transform.origin)

func _get_life() -> float:
	return creative_settings.Life if creative_settings else default_values["Life"]

func _set_life(value: float) -> void:
	if creative_settings:
		creative_settings.Life = value
	else:
		default_values["Life"] = value

func _get_kinetic_threshold() -> float:
	return creative_settings.kenetic_threshold if creative_settings else default_values["kenetic_threshold"]

func _get_explosion_scene() -> PackedScene:
	return creative_settings.Explosion_Scene if creative_settings else default_values["Explosion_Scene"]

func _handle_death() -> void:
	if not death_bit:
		UserData.game_vanquishes += creative_settings.VCredit if creative_settings else 0
		death_bit = true
	destroy_self()

func _set_freeze_state(bit: bool) -> void:
	freeze = bit
	sleeping = bit
