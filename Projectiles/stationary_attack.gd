extends Node2D
class_name StationaryAttack

#############
## VARIABLES
#############

var asyncTurnPool : AsyncTurnPool = ReferenceStash.asyncTurnPool

@export var travel_duration := .5

###########
## SIGNALS
###########

signal contact
signal collision_animation_finished

###########
## METHODS
###########

func contact_target() -> void:
	z_index = 25
	asyncTurnPool.add(self)
	
	contact.emit()
	print("emit")
	_animate_collision()
	await collision_animation_finished
	
	asyncTurnPool.remove(self)
	queue_free()

#############
## OVERRIDES
#############

func _animate_collision() -> void:
	await get_tree().process_frame
