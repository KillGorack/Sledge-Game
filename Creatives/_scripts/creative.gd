extends Camera3D


@export var creatives: Array[Resource] = []
@export var ray_distance: float = 50.0
@export var snap: float = 1.0
@export var creative_icon: TextureRect
@export var creative_label: Label
@export var creative_label_name: Label
@onready var raycast: RayCast3D = $"../TargetCast"



var cursor_instance: Node3D = null
var cursor_instance_nok: Node3D = null
var snapped_point: Vector3
var offset: Vector3 = Vector3(0, 0, 0)
var can_place: bool = false
var creative_mode_enabled: bool = false
var current_creative_index: int = 0
var creative_settings: Resource
var axis: Vector3 = Vector3(0, 1, 0)
var angle_degrees: float = 90

func _ready():
	raycast.enabled = true
	if creatives.size() > 0:
		creative_settings = creatives[current_creative_index]
	if Utilities.user_space_access == true:
		UserDataApi.get_user_space(creatives)





func _process(_delta: float):
	if Utilities.game_mode_index != 2 and creative_mode_enabled == false:
		return
	elif Utilities.game_mode_index != 2 and creative_mode_enabled == true:
		toggle_creative_mode()
	elif creative_mode_enabled == false:
		toggle_creative_mode()
	if not creative_mode_enabled or Utilities.user_space_access == false:
		return
		
	if Input.is_action_just_pressed("weapon_change"):
			change_creative()
			
	if Input.is_action_just_pressed("FireWeapon"):
			place_creative_item()

			
	if Input.is_action_just_pressed("rotate_i"):
		axis = Vector3(1, 0, 0)
		angle_degrees += 90
	if Input.is_action_just_pressed("rotate_j"):
		axis = Vector3(0, 1, 0)
		angle_degrees += 90
	if Input.is_action_just_pressed("rotate_k"):
		axis = Vector3(0, 0, 1)
		angle_degrees += 90
		
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		if abs(collision_normal.x) > 0.999:
			snapped_point = Vector3(
				collision_point.x + (0.5 * collision_normal.x),
				round(collision_point.y - 0.5) + 0.5,
				round(collision_point.z - 0.5) + 0.5
			)
		elif abs(collision_normal.y) > 0.999:
			snapped_point = Vector3(
				round(collision_point.x - 0.5) + 0.5,
				collision_point.y + (0.5 * collision_normal.y),
				round(collision_point.z - 0.5) + 0.5
			)
		elif abs(collision_normal.z) > 0.999:
			snapped_point = Vector3(
				round(collision_point.x - 0.5) + 0.5,
				round(collision_point.y - 0.5) + 0.5,
				collision_point.z + (0.5 * collision_normal.z)
			)
		else:
			cursor_instance_nok.global_transform.origin = collision_point + cursor_instance_nok.global_transform.basis.z * -0.5
			cursor_instance_nok.look_at((collision_point + cursor_instance_nok.global_transform.basis.z * -0.5) + collision_normal + Vector3(0.001, 0.001, 0.001), Vector3.UP)

		var cursor_transform = cursor_instance.global_transform
		cursor_transform.origin = snapped_point
		cursor_transform.basis = Basis().rotated(axis, deg_to_rad(angle_degrees))
		cursor_instance.global_transform = cursor_transform
		
		if abs(collision_normal.x) > 0.999 or abs(collision_normal.y) > 0.999 or abs(collision_normal.z) > 0.999:
			can_place = true
			cursor_instance.show()
			cursor_instance_nok.hide()
		else:
			can_place = false
			cursor_instance.hide()
			cursor_instance_nok.show()








func toggle_creative_mode():
	if creative_mode_enabled:
		creative_mode_enabled = false
		if cursor_instance and cursor_instance_nok:
			cursor_instance.queue_free()
			cursor_instance_nok.queue_free()
		cursor_instance = null
		creative_label.text = ""
		creative_icon.texture = null
	else:
		creative_mode_enabled = true
		if creative_settings.Cursor_Scene and cursor_instance == null and creative_settings.Cursor_Scene_NOK and cursor_instance_nok == null:
			cursor_instance = creative_settings.Cursor_Scene.instantiate()
			add_child(cursor_instance)
			cursor_instance_nok = creative_settings.Cursor_Scene_NOK.instantiate()
			add_child(cursor_instance_nok)
			creative_label.text = "Creative"
			current_creative_index = 0
			creative_settings = creatives[current_creative_index]
			update_creative_icon()





func change_creative():
	current_creative_index += 1
	if current_creative_index >= creatives.size():
		current_creative_index = 0
	creative_settings = creatives[current_creative_index]
	update_creative_icon()
	if cursor_instance:
		cursor_instance.queue_free()
		cursor_instance = creative_settings.Cursor_Scene.instantiate()
		add_child(cursor_instance)
	if cursor_instance_nok:
		cursor_instance_nok.queue_free()
		cursor_instance_nok = creative_settings.Cursor_Scene_NOK.instantiate()
		add_child(cursor_instance_nok)
	
	
	
	
	
func update_creative_icon():
	if creative_settings:
		creative_icon.texture = creative_settings.Icon
		creative_label_name.text = creative_settings.Name





func place_creative_item():
	if can_place and cursor_instance and not cursor_instance.get("player_colliding"):
		var creative_instance = creative_settings.Scene.instantiate()
		if creative_instance:
			if creative_instance.has_method("set_settings"):
				creative_instance.set_settings(creative_settings)
			get_parent().get_parent().get_parent().get_parent().add_child(creative_instance)
			creative_instance.global_transform = cursor_instance.global_transform
			
			
