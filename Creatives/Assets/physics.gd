extends RigidBody3D

@export var physics_material: PhysicsMaterial
var original_friction: float = 1.0
var stop_forces = false
var freezeBit: bool = false

func _ready() -> void:
	if physics_material:
		original_friction = physics_material.friction
	

func _process(_delta: float) -> void:
	pass

func setFreezeState(bit: bool) -> void:
	sleeping = bit
	freeze = bit
	freezeBit = bit
	if not bit:
		var freeze_timer = get_node_or_null("FreezeTimer")
		if freeze_timer:
			freeze_timer.queue_free()


func setTempFreese(delay: float) -> void:
	var init: bool = freeze
	freeze = true
	sleeping = true
	await get_tree().create_timer(delay).timeout
	freeze = init
	sleeping = init



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
