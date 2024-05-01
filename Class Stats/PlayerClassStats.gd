extends ClassStats
class_name PlayerClassStats

const MAX_EXPERIENCE := 100

@export var inventory : Resource

var experience := 0 : set = set_experience

signal experience_changed


func set_experience(value:int) -> void:
	experience = value
	while experience >= MAX_EXPERIENCE:
		experience = experience - MAX_EXPERIENCE
		level += 1
		level_changed.emit()
