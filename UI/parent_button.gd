extends Button
class_name ParentButton

@onready var focus_sfx = $FocusSFX
@onready var select_sfx = $SelectSFX



func _on_focus_entered():
	focus_sfx.play()
	



func _on_button_down():
	select_sfx.play()
