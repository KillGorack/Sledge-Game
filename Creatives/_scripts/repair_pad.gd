extends Area3D

@export var repair_rate: float = 10.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var health_node = body.get_node("Health") if body.has_node("Health") else null
		if health_node and health_node.has_method("set_on_repair_pad"):
			health_node.set_on_repair_pad(true)
	_trigger_reload_weapons(body)
	_trigger_reload_mines(body)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		var health_node = body.get_node("Health") if body.has_node("Health") else null
		if health_node and health_node.has_method("set_on_repair_pad"):
			health_node.set_on_repair_pad(false)

func _trigger_reload_weapons(body):
	var turret_node = body.get_node("Turret") if body.has_node("Turret") else null
	if turret_node:
		var barrel_node = turret_node.get_node("Barrel") if turret_node.has_node("Barrel") else null
		if barrel_node and barrel_node.has_method("reload_all_weapons"):
			barrel_node.reload_all_weapons()
			
func _trigger_reload_mines(body):
	var mines_node = body.get_node("Mines") if body.has_node("Mines") else null
	if mines_node and mines_node.has_method("reload_all_mines"):
			mines_node.reload_all_mines()
