extends RigidBody3D

@export var force: float = 400.0
@export var max_speed: float = 6.0
@export var turn_rate: float = 75.0
@export var turn_duration: float = 0.5
@export var left_raycast: RayCast3D
@export var right_raycast: RayCast3D
@export var ground_raycast: RayCast3D
@export var physics_material: PhysicsMaterial

var freezeBit: bool = false
var turn_timer = 0.0
var turn_direction = 1.0
var stop_forces = false
var original_friction: float = 1.0  # Default friction value

func _ready() -> void:
	if left_raycast:
		left_raycast.enabled = true
	if right_raycast:
		right_raycast.enabled = true
	if ground_raycast:
		ground_raycast.enabled = true
	if physics_material:
		original_friction = physics_material.friction

func _physics_process(_delta: float) -> void:
	apply_movement_and_turning()

func apply_movement_and_turning() -> void:
	if stop_forces or freezeBit == true:
		return

	var is_grounded = ground_raycast and ground_raycast.is_colliding()
	if is_grounded:
		_set_friction(original_friction)
		var forward_force = transform.basis.z * -force
		apply_central_force(forward_force)
		if (left_raycast and left_raycast.is_colliding()) or (right_raycast and right_raycast.is_colliding()):
			var turn_angle = deg_to_rad(turn_rate * turn_direction)
			rotation_degrees.y += rad_to_deg(turn_angle)
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed
	else:
		_set_friction(0)



func apply_directional_force(impulse: Vector3) -> void:
	stop_forces = true
	_set_friction(0)
	apply_central_impulse(impulse)
	await get_tree().create_timer(1.0).timeout
	_set_friction(original_friction)
	stop_forces = false


func _set_friction(value: float) -> void:
	if physics_material:
		physics_material.friction = value
		
		
func apply_damage(damage: float) -> void:
	get_node("Health").apply_direct_damage(damage)



	
func setFreezeState(bit: bool) -> void:
	sleeping = bit
	freeze = bit
	freezeBit = bit
	if not bit:
		var freeze_timer = get_node_or_null("FreezeTimer")
		if freeze_timer:
			freeze_timer.queue_free()
