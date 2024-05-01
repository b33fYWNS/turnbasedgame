extends FocusMenu
class_name ContextMenu

enum CONTEXT_OPTION {USE, INFO}

signal option_selected(option: CONTEXT_OPTION)

func _on_use_button_button_down() -> void:
	option_selected.emit(CONTEXT_OPTION.USE)

func _on_info_button_button_down() -> void:
	option_selected.emit(CONTEXT_OPTION.INFO)
