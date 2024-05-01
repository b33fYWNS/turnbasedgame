extends FocusMenu
class_name BattleMenu

const ANIMATION_DURATION := 0.4
const ANIMATION_DISTANCE := Vector2(0,36)

enum {
	ACTION,
	ITEM,
	RUN
}

@onready var action_button = %ActionButton
@onready var run_button = %RunButton
@onready var item_button = %ItemButton

signal menu_option_selected(option)
	
func show_menu() -> void:
	show()
	var tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", 
	-ANIMATION_DISTANCE, 
	ANIMATION_DURATION).as_relative().from_current()
	await tween.finished
	
func hide_menu() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 
	"global_position", 
	ANIMATION_DISTANCE, 
	ANIMATION_DURATION).as_relative().from_current()
	await tween.finished
	hide()
	
func _on_action_button_button_down():
	emit_signal("menu_option_selected", ACTION)
	
func _on_item_button_button_down():
	emit_signal("menu_option_selected", ITEM)

func _on_run_button_button_down():
	emit_signal("menu_option_selected", RUN)
