extends Node2D
class_name Projectile

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

func move_to(target:BattleUnit, trans : int = Tween.TRANS_LINEAR, easing : int = Tween.EASE_IN) -> void:
	z_index = 25
	var tween := create_tween().set_trans(trans).set_ease(easing)
	var target_position := target.global_position
	tween.tween_property(self, "global_position", target_position, travel_duration).from_current()
	await tween.finished
	
	contact.emit()
	
	_animate_collision()
	await collision_animation_finished
	
	queue_free()

#############
## OVERRIDES
#############

func _animate_collision() -> void:
	await get_tree().process_frame
