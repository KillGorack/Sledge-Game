extends Node3D

@export var load_user_space: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Utilities.set_user_space_access(load_user_space)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
