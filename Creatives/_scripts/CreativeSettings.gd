extends Resource
class_name CreativeSettings

@export var Name: String = "Creative"
@export var Icon: Texture
@export var Scene: PackedScene
@export var Cursor_Scene: PackedScene
@export var Cursor_Scene_NOK: PackedScene
@export var Explosion_Scene: PackedScene
@export var Life:  = 100.0
@export var kenetic_threshold: float = 50.0
@export var Rotatable: bool = false
@export var Frozen: bool = true
@export var VCredit: int = 0
@export var Layer: int = 1
@export var PlacementSound: AudioStream
@export var Explosion_Sound: AudioStream
