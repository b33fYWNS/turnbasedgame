extends Node2D
class_name DamageNumber

@onready var label = $Container/Label
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_damage_number(damage_amount : int) -> void:
	label.text = str(damage_amount)
	animation_player.play("Number_Fade")
	await animation_player.animation_finished
	queue_free()
func set_critical_damage_number(damage_amount : int) -> void:
	label.text = str(damage_amount) + "!!"
	animation_player.play("Number_Fade")
	await animation_player.animation_finished
	queue_free()
