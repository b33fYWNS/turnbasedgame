extends TextureRect

const CHAR_DISPLAY_DURATION: float = 0.08

var typer : Tween
var is_typing : bool = false
var pitch: float = 1.0

@onready var text_box = %TextBox
@onready var portrait = %Portrait
@onready var voice = $AudioStreamPlayer
@onready var character_name = $HboxContainer/CharacterName


func _ready() -> void:
	Events.request_show_dialog.connect(type_dialog)
	

func _unhandled_input(event) -> void:
	if not visible: return
	if not event.is_action_pressed("ui_accept"): return
	
	if is_typing:
		is_typing = false
		if typer is Tween: typer.kill()
		text_box.visible_ratio = 1.0
	else:
		hide()
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		Events.dialog_finished.emit()
	

func type_dialog(bbcode : String, character : Character) -> void:
	is_typing = true
	portrait.texture = character.portrait
	character_name.text = "" + str(character.name)
	global_position = character.location
	pitch = character.voice_pitch
	get_tree().paused = true
	show()
	text_box.text = bbcode
	
	var total_characters: int = text_box.text.length()
	var duration: float = total_characters*CHAR_DISPLAY_DURATION
	
	typer = create_tween()
	typer.tween_method(set_visible_characters, 0, total_characters,duration)
	await typer.finished
	
	is_typing = false

func set_visible_characters(index: int) -> void:
	text_box.visible_characters = index

	var is_new_character: bool = index > text_box.visible_characters
	if is_new_character and index < text_box.get_total_character_count():
		var character = text_box.text.substr(text_box.visible_characters, 1)
		voice.pitch_scale = randf_range(pitch - 0.1, pitch + 0.1)
		voice.play()
