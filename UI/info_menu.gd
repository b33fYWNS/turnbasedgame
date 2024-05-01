extends FocusMenu
class_name InfoMenu

@onready var info_text = %InfoText

var text : String = "" : set = set_text

func set_text(value:String) -> void:
	text = value
	info_text.text = text
