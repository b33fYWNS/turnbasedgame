extends Projectile

@onready var flame = $Flame
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var explosion = $Explosion
@onready var fire_impact_sfx = $FireImpactSFX

func _ready() -> void:
	Events.emit_signal("request_show_battle_message", "Yuria's Flame")

func _animate_collision() -> void:
	fire_impact_sfx.play()
	animated_sprite_2d.hide()
	flame.hide()
	explosion.emitting = true
	while explosion.emitting == true:
		await get_tree().process_frame
	collision_animation_finished.emit()
