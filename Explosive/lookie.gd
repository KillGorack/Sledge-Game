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
			look_at(camera.global_transform.origin, Vector3.UP)

func _on_Timer_timeout() -> void:
	queue_free()
