extends Area3D

var player_colliding: bool = false

func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_colliding = true 

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_colliding = false
