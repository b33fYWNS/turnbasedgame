extends Resource
class_name Character

@export var name : String
@export var portrait : Texture
@export var location : Vector2
@export_range(0.5, 1.5, 0.1) var voice_pitch: float = 1.0
