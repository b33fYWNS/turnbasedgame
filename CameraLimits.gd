extends ColorRect
class_name CameraLimits

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	var camera_limits := Rect2(self.global_position, self.size)
	Events.request_update_camera_limits.emit(camera_limits)
	hide()
