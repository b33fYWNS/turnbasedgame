extends StationaryAttack

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	Events.emit_signal("request_show_battle_message", "Agora's Light")

func _on_animation_player_animation_finished(anim_name : String) -> void:
	if anim_name != "Start": return
	animation_player.play("Attack")
	await animation_player.animation_finished
	animation_player.play("End")
	await animation_player.animation_finished
	
	collision_animation_finished.emit()
	queue_free()
	
