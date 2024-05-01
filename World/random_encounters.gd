extends Sprite2D

@export var encounters: Array[ClassStats] = []

func _ready() -> void: 
	randomize()
	ReferenceStash.random_encounters = encounters
	hide()
	
func _exit_tree() -> void:
	ReferenceStash.random_encounters = []
	request_ready()
