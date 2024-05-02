extends Node2D
class_name DamageNumber

@onready var label = $Container/Label
@onready var animation_player = $AnimationPlayer
@onready var weak_label = $Container/WeakLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	var battle_unit = get_parent()

func set_damage_number(damage_amount : int, is_weak: bool = false) -> void:
	label.text = str(damage_amount)
	if is_weak:
		set_weak_text()
	animation_player.play("Number_Fade")
	await animation_player.animation_finished
	queue_free()
	
func set_critical_damage_number(damage_amount : int, is_weak: bool = false) -> void:
	label.text = str(damage_amount) + "!!"
	if is_weak:
		set_weak_text()
	animation_player.play("Number_Fade")
	await animation_player.animation_finished
	queue_free()
