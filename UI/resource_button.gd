extends ParentButton
class_name ResourceButton

var resource : Resource

signal resource_selected(resource)

func _on_button_down():
	resource_selected.emit(resource)
