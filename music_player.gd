extends Node

var stack := []

@onready var town_music = $Town_Music
@onready var battle_music = $Battle_Music

func push_song(song : AudioStreamPlayer) -> void:
	if not stack.is_empty(): stack.back().stream_paused = true
	stack.append(song)
	song.play()
		
func pop_song() -> void:
	if stack.is_empty(): return
	var current_song : AudioStreamPlayer = stack.pop_back()
	var volume_fade = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	volume_fade.tween_property(current_song, "volume_db", -50,-10).from_current()
	await volume_fade.finished
	current_song.stop()
	current_song.volume_db = -10
	var last_song : AudioStreamPlayer = stack.back()
	last_song.volume_db = -50
	last_song.stream_paused = false
	var volume_rise = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	volume_rise.tween_property(last_song, "volume_db",-10, -10).from_current()
