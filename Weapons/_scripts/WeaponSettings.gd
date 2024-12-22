extends Resource
class_name WeaponSettings

@export var weapon_name: String = "Default Weapon"
@export var weapon_icon: Texture
@export var level_req: int = 1
@export var power_consumption: float = 0.0
@export var projectile_count_capacity: float = 1.0
@export var projectile_count_actual: float = 1.0

enum WeaponType { Default, Force, Pierce, Explosive, Bounce }
@export var weapon_type: WeaponType = WeaponType.Default

@export var projectile_pierce_count: int = 0
@export var projectile_ricochet_count: int = 0
@export var bounce_count: int = 0

@export var explosive_force: float = 0.0
@export var explosive_force_distance: float = 0.0

@export var targeting_system: bool = false
@export var targeting_system_require_marker: bool = true
@export var target_rotation_speed: float = 0.0
@export var target_system_scan_radius: float = 40
@export var target_system_group: String = "Creative"

@export var freeze_timer: float = 0.0;

@export var projectile_prefab: PackedScene
@export var explosion_prefab: PackedScene
@export var bullet_hole_prefab: PackedScene


@export var projectile_count: int = 1
@export var projectile_spacing: float = 0.0
@export var projectile_start_angle: float = 0.0
@export var projectile_recoil: float = 0.0
@export var projectile_range: float = 100.0
@export var projectile_speed: float = 45.0
@export var projectile_spin: float = 0.0
@export var projectile_force: float = 0.0
@export var bi_directional: bool = false
@export var hit_points: float = 0.0
@export var cool_down: float = 0.5
@export var launch_offset: float = -0.5
@export var projectile_fire_delay: float = 0.0
@export var projectile_destruction_delay: float = 0.0
@export var mass: float = 1.0
@export var use_gravity: bool = false
@export var launch_sound: AudioStream
@export var hit_sound: AudioStream

@export var layer: int = 1
@export var layer_mask: Array[int] = []

func set_layer(value: int) -> void:
	if value >= 1 and value <= 32:
		layer = value
		
func set_layer_mask(value: Array[int]) -> void:
	if value.is_empty():
		return
	var max_value = value.max()
	var min_value = value.min()
	if max_value > 32 or min_value < 1:
		return
	layer_mask = value
