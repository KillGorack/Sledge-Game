extends Node3D

@export var shield_mesh: MeshInstance3D
@export var life: float = 100.0
@export var armor: float = 100.0
@export var shield: float = 100.0
@export var Interactive: bool = false
@export var hud_shields: Label
@export var hud_armor: Label
@export var hud_health: Label
@export var hud_draw_target: Control
@export var regeneration_delay: float = 5.0
@export var regeneration_rate: float = 10.0

var shield_original: float
var armor_original: float
var life_original: float
var parent_node = get_parent()
var regeneration_timer: Timer
var is_regenerating: bool = false
var on_repair_pad: bool = false
var distructo: bool = false

func _ready() -> void:
	shield_original = shield
	armor_original = armor
	life_original = life
	parent_node = get_parent()
	_update_hud()
	_draw_hud_circle()
	regeneration_timer = Timer.new()
	regeneration_timer.set_wait_time(regeneration_delay)
	regeneration_timer.set_one_shot(true)
	regeneration_timer.connect("timeout", Callable(self, "_on_regeneration_timeout"))
	add_child(regeneration_timer)





func _process(_delta: float) -> void:
	if global_transform.origin.y < -25:
		destroy_self()
	if on_repair_pad:
		if life < life_original:
			life = min(life_original, life + regeneration_rate * _delta)
		elif armor < armor_original:
			armor = min(armor_original, armor + regeneration_rate * _delta)
		elif shield < shield_original:
			shield = min(shield_original, shield + regeneration_rate * _delta)
		_update_hud()
		_draw_hud_circle()
	elif is_regenerating and shield < shield_original:
		shield = min(shield_original, shield + regeneration_rate * _delta)
		_update_hud()
		_draw_hud_circle()





func apply_direct_damage(damage: float) -> void:
	apply_damage(damage)
	if life <= 0:
		destroy_self()





func apply_damage(damage: float) -> void:
	regeneration_timer.start() # Restart the timer on taking damage
	is_regenerating = false    # Stop regeneration when taking damage
	if shield > 0:
		shield -= damage
		if shield <= 0:
			if shield_mesh and is_instance_valid(shield_mesh): 
				shield_mesh.visible = false
			damage = -shield
			shield = 0
		else:
			_update_hud()
			_draw_hud_circle()
			return
	if armor > 0 and damage > 0:
		armor -= damage
		if armor < 0:
			damage = -armor
			armor = 0
		else:
			_update_hud()
			_draw_hud_circle()
			return
	if damage > 0:
		life -= damage
	_update_hud()
	_draw_hud_circle()
	if life <= life_original * 0.7 and Interactive == true:
		if parent_node and parent_node.has_method("setFreezeState"):
			parent_node.call("setFreezeState", false)





func destroy_self() -> void:
	var main_menu = get_tree().get_root().get_node("MainMenu")
	if main_menu:
		var load_group = main_menu.get_node_or_null("LoadGroup")
		if load_group and load_group.has_method("playerDestroyed") and distructo == false:
			load_group.call("playerDestroyed")
			distructo = true





func _update_hud() -> void:
	if hud_shields:
		hud_shields.text = "S: %d" % int(shield)
	if hud_armor:
		hud_armor.text = "A: %d" % int(armor)
	if hud_health:
		hud_health.text = "H: %d" % int(life)





func _draw_hud_circle() -> void:
	if hud_draw_target and hud_draw_target is Control:
		var shield_progress = shield / shield_original
		var armor_progress = armor / armor_original
		var life_progress = life / life_original
		hud_draw_target.set_circle_properties(shield_progress, "shield")
		hud_draw_target.set_circle_properties(armor_progress, "armor")
		hud_draw_target.set_circle_properties(life_progress, "life")





func _on_regeneration_timeout() -> void:
	is_regenerating = true





func set_on_repair_pad(value: bool) -> void:
	on_repair_pad = value
