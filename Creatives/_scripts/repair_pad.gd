extends Area3D

@export var repair_rate: float = 10.0 # Amount of health restored per second

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):  # Assuming the player node is in the "Player" group
		body.get_child(0).set_on_repair_pad(true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.get_child(0).set_on_repair_pad(false)
