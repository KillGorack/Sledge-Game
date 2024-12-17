extends RigidBody3D

const MAX_SPEED = 6.0
const ACCELERATION = 400.0
const DECELERATION = 100.0
const TURN_SPEED = 3.0
const TURN_ACCELERATION = 12.0
const TURN_DECELERATION = 25.0
const SPEED_THRESHOLD = 0.01
const RIGHT_SIDE_UP_THRESHOLD = 0.6
const UNTURTLE_THRESHOLD = 0.3
const UNTURTLE_FORCE = 100.0
const THRUSTER_FORCE = 800.0
const ROTATION_SPEED =  5.0

var isGrounded = false
var rotational_velocity_set_to_zero = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var engine_audio: AudioStreamPlayer
var target_pitch = 2.0
var target_volume = -30.0
var pitch_transition_speed = 5.0
var volume_transition_speed = 5.0
var current_turn_speed = 0.0
var original_friction: float = 1.0
var stop_forces = false

@export var physics_material: PhysicsMaterial
@export var engine_audio_path: NodePath
@onready var ground_check_area = $GroundCheck
@export var speedometer: Label
@export var speedometer_graphic: Control



func _ready():
	engine_audio = get_node(engine_audio_path) as AudioStreamPlayer
	if engine_audio:
		engine_audio.play()
	if physics_material:
		original_friction = physics_material.friction

func _physics_process(delta):
	var forward_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var turn_input = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	isGrounded = ground_check_area.get_overlapping_bodies().size() > 0
	if Input.is_action_pressed("unturtle"):
		activate_thrusters(delta)
	else:
		if is_right_side_up() and isGrounded:
			rotational_velocity_set_to_zero = false
			adjust_rotation(turn_input, delta)
			move_player(forward_input)
	if rotational_velocity_set_to_zero:
		set_angular_velocity(Vector3.ZERO)
	update_engine_sound()
	var ps = linear_velocity.length() / MAX_SPEED
	speedometer_graphic.set_speed_ratio(ps)







func is_right_side_up() -> bool:
	return transform.basis.y.dot(Vector3.UP) > RIGHT_SIDE_UP_THRESHOLD




func adjust_rotation(turn_input, delta):
	current_turn_speed = move_toward(current_turn_speed, turn_input * TURN_SPEED, TURN_ACCELERATION * delta)
	rotation.y += current_turn_speed * delta





func move_player(forward_input):
	if stop_forces:
		return
	var direction = transform.basis.z
	if forward_input != 0:
		var force = direction * forward_input * ACCELERATION
		apply_central_force(force)
	else:
		var current_velocity = get_linear_velocity()
		var deceleration_force = -current_velocity * DECELERATION
		apply_central_force(deceleration_force)
	if isGrounded:
		var clamped_velocity = get_linear_velocity().limit_length(MAX_SPEED)
		set_linear_velocity(clamped_velocity)





func activate_thrusters(delta):
	apply_central_force(Vector3.UP * THRUSTER_FORCE)
	var current_up = transform.basis.y
	var target_up = Vector3.UP
	var rotation_axis = current_up.cross(target_up).normalized()
	var angle_diff = acos(current_up.dot(target_up))
	if angle_diff > 0.1:
		var torque = rotation_axis * min(ROTATION_SPEED * delta, angle_diff)
		apply_torque_impulse(torque)
	else:
		rotational_velocity_set_to_zero = true







func update_engine_sound():
	if engine_audio:
		var speed : float = get_linear_velocity().length()
		if isGrounded:
			target_pitch = clamp(2.0 + speed / max(MAX_SPEED, 1.0) * 2.0, 2.0, 4.0)
			target_volume = clamp(-20 + 10 * (speed / max(MAX_SPEED, 1.0)), -60.0, -20.0)
		else:
			target_pitch = 2.0
			target_volume = -20.0
		engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, target_pitch, pitch_transition_speed * get_process_delta_time())
		engine_audio.volume_db = lerp(engine_audio.volume_db, target_volume, volume_transition_speed * get_process_delta_time())


func _set_friction(value: float) -> void:
	if physics_material:
		physics_material.friction = value
		
func apply_directional_force(impulse: Vector3) -> void:
	stop_forces = true
	_set_friction(0)
	apply_central_impulse(impulse)
	await get_tree().create_timer(1.0).timeout
	_set_friction(original_friction)
	stop_forces = false
