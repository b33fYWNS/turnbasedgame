extends CharacterBody2D
class_name OverworldPlayer

const WALK_SPEED = 80
const MAX_ENCOUNTER_METER:= 100
const MIN_ENCOUNTER_CHANCE:= 0.1
const ENCOUNTER_METER_REDUCTION_AMOUNT := 75

var encounter_meter := MAX_ENCOUNTER_METER
var encounter_chance := MIN_ENCOUNTER_CHANCE
var last_door_connection : int = -1

@onready var animated_sprite = $AnimatedSprite2D
@onready var interactable_detector = $InteractableDetector
@onready var enter_new_area = $Sounds/EnterNewArea
@onready var use_door = $Sounds/UseDoor
@onready var encounter_sfx = $Sounds/EncounterSFX



#############
## OVERRIDES
#############

func _init() -> void:
	# Free the instance of the player in case one exists in the level swapper already
	if LevelSwapper.player is OverworldPlayer:
		queue_free()


func _ready() -> void:
	if not LevelSwapper.player is OverworldPlayer:
		ReferenceStash.player = self
	interactable_detector.rotation = Vector2.DOWN.angle()
	

func _physics_process(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up","ui_down")
	velocity = input_vector * WALK_SPEED
	move_and_slide()
	
	if is_moving():
		animate_walk()
		interactable_detector.rotation = velocity.angle()
		encounter_check(delta)
	else:
		animate_idle()
		
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var interactables :Array= interactable_detector.get_overlapping_bodies()
		for interactable in interactables:
			if not interactable is Interactable: continue
			interactable._run_interaction()
			get_viewport().set_input_as_handled()
		#Events.emit_signal("request_show_message", "New Message")
		#SceneStack.push("res://Battle/battle.tscn")
	if event.is_action_pressed("ui_cancel"):
		Events.request_show_overworld_menu.emit()
		get_viewport().set_input_as_handled()
	
###########
## METHODS
###########

func is_moving() -> bool:
	return velocity != Vector2.ZERO
	
func encounter()->void:
	var random_encounters = ReferenceStash.random_encounters
	if random_encounters.is_empty(): return
	random_encounters.shuffle()
	ReferenceStash.encounter_class = random_encounters.front()
	SceneStack.push("res://Battle/battle.tscn")
	
	
func encounter_check(delta:float):
	encounter_meter -= ENCOUNTER_METER_REDUCTION_AMOUNT * delta
	if encounter_meter <= 0:
		encounter_meter = MAX_ENCOUNTER_METER
		if Math.chance(encounter_chance):
			encounter_chance = MIN_ENCOUNTER_CHANCE
			encounter()
		else:
			encounter_chance = min(encounter_chance + .1, 1)

func animate_walk() -> void:
	var angle : float = velocity.angle()
	var angle_in_degree : float = rad_to_deg(angle)
	var rounded_angle : int = int(round(angle_in_degree/45)*45)
	match rounded_angle:
		-135, 180, 135: animated_sprite.animation = "WalkLeft"
		0, -45, 45: animated_sprite.animation = "WalkRight"
		-90: animated_sprite.animation = "WalkUp"
		90: animated_sprite.animation = "WalkDown"
		
func animate_idle() -> void:
	match animated_sprite.animation:
		"WalkLeft": animated_sprite.animation = "IdleLeft"
		"WalkRight": animated_sprite.animation = "IdleRight"
		"WalkUp": animated_sprite.animation = "IdleUp"
		"WalkDown": animated_sprite.animation = "IdleDown"

func go_to_new_area(new_area_path : String) -> void:
	
	#get_tree().paused = true
	await Transition.fade_to_color(Color.BLACK)
	#get_tree().paused = false
	encounter_meter = MAX_ENCOUNTER_METER
	LevelSwapper.level_swap(self, new_area_path)
	Transition.fade_from_color(Color.BLACK)

#####################
## SIGNALS CALLBACKS
#####################

func _on_door_detector_area_entered(door : Area2D) -> void:
	if not door is Door: return
	door = door as Door
	if door.new_area.is_empty():
		return
	last_door_connection = door.connection
	if door.door_sound_effect:
		use_door.play()
	else:
		enter_new_area.play()
	call_deferred("go_to_new_area", door.new_area)
