extends Camera2D
class_name OverworldCamera

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.request_update_camera_limits.connect(_on_request_update_camera_limits)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_request_update_camera_limits(limits : Rect2) -> void:
	limit_left = limits.position.x
	limit_right = limits.end.x
	limit_top = limits.position.y
	limit_bottom = limits.end.y
	pass
