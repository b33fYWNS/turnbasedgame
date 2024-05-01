extends Resource
class_name ClassStats

@export var charactername : String
@export var max_health : int : set = set_max_health
@export var attack : int
@export var defense : int
@export var crit_chance : float = 0.1

@export var BattleAnimations : PackedScene

@export var battle_actions : Array[Resource]
@export var ai : Script = null

var level := 1
var health: int = 1:
	set = set_health

signal health_changed
signal no_health
signal max_health_changed
signal level_changed

func set_max_health(value:int) -> void:
	max_health = value
	set_health(max_health)
	max_health_changed.emit()

func set_health(value:int) -> void:
	health = clamp(value, 0 , max_health)
	health_changed.emit()
	
	if health == 0:
		no_health.emit()
		
func _init():
	self.health = max_health
