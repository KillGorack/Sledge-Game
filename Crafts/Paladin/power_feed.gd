extends Node3D

@export var powermeter_graphic: Control
@export var powerCapacity: float = 100
var currentPower: float = 5
@export var powerGainRate: float = 10.0
@export var maxEffectDistance: float = 15.0

func _ready():
	powermeter_graphic.update_power_meter(0)
	
func _process(delta: float) -> void:
	adjust_power_based_on_distance(delta)
	var pr = currentPower / powerCapacity
	powermeter_graphic.update_power_meter(pr)

func adjust_power_based_on_distance(delta: float) -> void:
	var recon_nodes = get_tree().get_nodes_in_group("Recon")
	var total_power_gain = 0.0

	for recon_node in recon_nodes:
		if recon_node is Node3D:
			var distance = global_transform.origin.distance_to(recon_node.global_transform.origin)
			if distance <= maxEffectDistance:
				var power_ratio = 1.0 - (distance / maxEffectDistance)
				total_power_gain += powerGainRate * power_ratio * delta
	currentPower = clamp(currentPower + total_power_gain, 0, powerCapacity)
	
func spendPower(consumed: float):
	currentPower -= consumed

func getPower():
	return currentPower
