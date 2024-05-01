extends CenterContainer

@onready var label = %Label
@onready var battle_animations : BattleAnimations
@onready var timer = $"../Timer"


func _ready() -> void:
	Events.request_show_message.connect(show_message)
	Events.request_show_battle_message.connect(show_battle_message)
	
func _input(event : InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		get_viewport().set_input_as_handled()
		hide()

func show_message(message: String) -> void:
	show()
	get_tree().paused = true
	label.text = message
	
func show_battle_message(message: String) -> void:
	show()
	get_tree().paused = false
	label.text = message
	timer.start(1)
	await timer.timeout
	hide()
	

