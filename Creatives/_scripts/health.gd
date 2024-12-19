extends Node3D

@export var explosion: PackedScene
@export var explosionSound: AudioStream
@export var shield_mesh: MeshInstance3D
@export var life: float = 100.0
@export var armor: float = 100.0
@export var shield: float = 100.0
@export var Interactive: bool = false
@export var VCredit: int = 0
var life_original: float
var parent_node = get_parent()
var death_bit: bool = false


func _ready() -> void:
	life_original = life
	parent_node = get_parent()






func _process(_delta: float) -> void:
	if global_transform.origin.y < -25:
		destroy_self()





func apply_direct_damage(damage: float) -> void:
	apply_damage(damage)
	if life <= 0:
		if death_bit == false:
			UserData.game_vanquishes += VCredit
			death_bit = true
		destroy_self()





func apply_damage(damage: float) -> void:
	if shield > 0:
		shield -= damage
		if shield <= 0:
			if shield_mesh and is_instance_valid(shield_mesh): 
				shield_mesh.visible = false
			damage = -shield
			shield = 0
		else:
			return
	if armor > 0 and damage > 0:
		armor -= damage
		if armor < 0:
			damage = -armor
			armor = 0
		else:
			return
	if damage > 0:
		life -= damage
	if life <= life_original * 0.7 and Interactive == true:
		if parent_node and parent_node.has_method("setFreezeState"):
			parent_node.call("setFreezeState", false)





func destroy_self() -> void:
	if explosion:
		var instance = explosion.instantiate()
		get_parent().get_parent().add_child(instance)
		call_deferred("_set_instance_properties", instance)
		Utilities.play_sound(explosionSound, global_transform.origin)
	get_parent().queue_free()





func _set_instance_properties(instance: Node) -> void:
	instance.global_transform.origin = global_transform.origin
	instance.scale = Vector3(5, 5, 5)
