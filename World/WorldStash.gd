extends Node

var data : Dictionary = {}

func get_id(node : Node) -> String:
	var main : Node = get_tree().current_scene
	return (
		main.name
		+ "_"
		+ node.name
		+ str(node.global_position)
	)
	
func stash(id: String, key : String, value):
	data[id] = {}
	data[id][key] = value
	
func retrieve(id:String,key:String):
	if not data.has(id):return null
	if not data[id].has(key): return null
	return data[id][key]
	
func _ready():
	var music_player = $MusicPlayer  # Assuming you have a reference to your music player node
	var music_volume = retrieve("music_player_volume", "volume_db")
	if music_volume != null:
		music_player.volume_db = music_volume
