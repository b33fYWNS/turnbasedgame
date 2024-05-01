extends Interactable

#############
## CONSTANTS
#############

const PICKUP_SOUND_DURATION: float = 0.3

#############
## VARIABLES
#############

var inventory : Inventory = ReferenceStash.inventory

@onready var pickup_sound = $PickupSound
@onready var pickup_sound_timer = $PickupSoundTimer
@export var item : Item : set = set_item
@onready var sprite_2d = $Sprite2D
@onready var id := WorldStash.get_id(self)

#############
## OVERRIDES
#############

func _ready() -> void:
	if WorldStash.retrieve(id,"freed"):
		queue_free()
		

func _run_interaction() -> void:
	inventory.add_item(item)
	pickup_sound_timer.start(PICKUP_SOUND_DURATION)
	pickup_sound.play()
	await pickup_sound_timer.timeout
	WorldStash.stash(id,"freed",true)
	Events.emit_signal("request_show_message", "You found " + str(item.name))
	
	queue_free()
		
###########
## METHODS
###########

func set_sprite_texture(item_candidate : Item) -> void:
	if not sprite_2d:
		return
	sprite_2d.texture = item_candidate.overworld_sprite
	
###########
## SETTERS
###########

func set_item(value : Item) -> void:
	item = value
	call_deferred("set_sprite_texture", item)




	
