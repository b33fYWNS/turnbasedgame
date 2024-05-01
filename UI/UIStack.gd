extends Resource
class_name UIStack

var uis : Array[Control] = []

signal ui_popped(ui)
signal ui_stack_empty()

func push(uiToPush : Control) -> void:
	if not empty(): 
		uis.back().release_menu_focus()
	uis.append(uiToPush)
	uiToPush.show()
	if uiToPush is FocusMenu:
		uiToPush.grab_menu_focus()
	elif uiToPush is Control:
		uiToPush.grab_focus()

func pop() -> Control:
	if empty(): 
		return null
	var uiToPop : Control = uis.pop_back()
	if uiToPop is FocusMenu:
		uiToPop.release_menu_focus() # Must release focus before hiding UI
	elif uiToPop is Control:
		uiToPop.release_focus()

	uiToPop.hide()
	if not empty():
		uis.back().show()
		if uis.back() is FocusMenu:
			uis.back().grab_menu_focus()
		elif uis.back() is Control:
			uis.back().grab_focus()
	ui_popped.emit(uiToPop)
	if empty():
		ui_stack_empty.emit()
	return uiToPop
	
func hide_uis() -> void:
	for ui in uis:
		ui.hide()
		
func clear() -> void:
	hide_uis()
	uis.clear()
	
func empty() -> bool:
	return uis.is_empty()
