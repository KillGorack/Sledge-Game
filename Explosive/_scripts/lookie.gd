extends Node3D

@export var destruction_delay: float = 5
@onready var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.wait_time = destruction_delay
	timer.one_shot = true
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()

func _process(_delta: float) -> void:
	var viewport = get_viewport()
	if viewport:
		var camera = viewport.get_camera_3d()
		if camera:
			var direction = (camera.global_transform.origin - global_transform.origin).normalized()
			# Check if the direction is nearly parallel to Vector3.UP
			if abs(direction.dot(Vector3.UP)) > 0.99:
				# Slightly adjust the target position to avoid parallel vectors
				direction += Vector3(0.1, 0, 0).normalized()
			look_at(global_transform.origin + direction, Vector3.UP)

func _on_Timer_timeout() -> void:
	queue_free()
