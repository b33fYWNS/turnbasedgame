extends TextureRect

@onready var increase = $Increase
@onready var decrease = $Decrease
@onready var actual = $Actual
@onready var portrait = $Portrait

signal animation_finished

var bar_value : float = 0.0

#func _ready():
	#await animate_bar(95,100)
	#await animate_bar(5,100)
	#await animate_bar(95,100)
	#await animate_bar(50,100)
	

func set_bar_value(value:float,max_value:float)-> void:
	bar_value = (value/max_value)*100

func set_bar(value:float, max_value : float) -> void:
	bar_value = (value/max_value)*100
	decrease.value = bar_value
	increase.value = bar_value
	actual.value = bar_value
	
func animate_bar(value:float,max_value:float,duration : float = 1) -> void:
	if not is_inside_tree(): return
	var previous_bar_value = bar_value
	set_bar_value(value,max_value)
	var tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	if bar_value > previous_bar_value:
		decrease.value=bar_value
		increase.value=bar_value
		tween.tween_property(actual, "value", bar_value, duration).from_current()
		await tween.finished
	elif bar_value < previous_bar_value:
		actual.value = bar_value
		increase.value = bar_value
		tween.tween_property(decrease, "value", bar_value, duration).from_current()
		await tween.finished
	else:
		tween.kill()
	emit_signal("animation_finished")
