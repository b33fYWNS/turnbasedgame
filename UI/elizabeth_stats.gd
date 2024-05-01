extends PanelContainer
class_name ElizabethStats

#############
## VARIABLES
#############

var stats : PlayerClassStats = ReferenceStash.elizabethStats

@onready var charactername = %Name
@onready var level = %Level
@onready var attack = %Attack
@onready var defense = %Defense
@onready var health_bar = %HealthBar
@onready var experience_bar = %ExperienceBar

###########
## SIGNALS
###########

signal animation_finished

#############
## OVERRIDES
#############

func _ready() -> void:
	if not stats.health_changed.is_connected(_on_health_changed):
		stats.health_changed.connect(_on_health_changed)
	update_stats()
	
###########
## METHODS
###########

func update_stats() -> void:
	charactername.text = "Name : " + str(stats.charactername)
	level.text = "Level : " + str(stats.level)
	attack.text = "Attack : " + str(stats.attack)
	defense.text = "Defense : " + str(stats.defense)
	health_bar.set_bar(stats.health, stats.max_health)
	experience_bar.set_bar(stats.experience, stats.MAX_EXPERIENCE)
	
func _on_health_changed() -> void:
	health_bar.animate_bar(stats.health, stats.max_health)
	await health_bar.animation_finished
	animation_finished.emit()
	
func _exit_tree() -> void:
	request_ready()
