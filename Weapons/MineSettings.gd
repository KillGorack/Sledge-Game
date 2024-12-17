extends Resource
class_name MineSettings

@export var mine_name: String = "Mine"
@export var mine_icon: Texture
@export var level_req: int = 1
@export var max_count: int = 1
@export var target_group: String = "Creative"
@export var scan_time: float = 0.2
@export var cool_down: float = 0.5
@export var count_capacity: float = 1.0
@export var count_actual: float = 1.0
@export var mine_prefab: PackedScene
@export var explosion_prefab: PackedScene
@export var crater_prefab: PackedScene
@export var hit_points: float = 0.0
@export var explosive_force: float = 0.0
@export var explosive_force_distance: float = 0.0
@export var freeze_timer: float = 0.0;
@export var lay_sound: AudioStream
@export var unfreeze: bool = false
@export var triggerable: bool = false
@export var activation_range: float = 1.0
@export var life_span: float = 900.0
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
