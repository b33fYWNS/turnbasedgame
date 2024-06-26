extends NPC

const ELIZABETH_CHARACTER : Character = preload("res://Characters/ElizabethCharacter.tres")
const APPLE_ITEM : Item = preload("res://Items/AppleItem.tres")

var inventory : Inventory = ReferenceStash.inventory

var has_apple := false

@onready var id := WorldStash.get_id(self)

func _ready():
	if WorldStash.retrieve(id,"has_apple"):
		has_apple = true

func _run_interaction() -> void:
	if not has_apple:

		Events.request_show_dialog.emit("A new arrival I see.", character)
		await Events.dialog_finished
		Events.request_show_dialog.emit("Be wary of the twisted beasts that spew forth from this Church.", character)
		await Events.dialog_finished
		
		#var apple = inventory.remove_item(APPLE_ITEM)
		
		#if apple is Item:
			#Events.request_show_dialog.emit("I do.", ELIZABETH_CHARACTER)
			#await Events.dialog_finished
			#Events.request_show_dialog.emit("Here you go.", ELIZABETH_CHARACTER)
			#await Events.dialog_finished
			#has_apple = true
			#WorldStash.stash(id,"has_apple",true)
		#else:
			#Events.request_show_dialog.emit("I'll look around for you.", ELIZABETH_CHARACTER)
			#await Events.dialog_finished
	#if has_apple:
		#Events.request_show_dialog.emit("I feel much better now.", character)
		#await Events.dialog_finished
		#Events.request_show_dialog.emit("Thank you.", character)
		#await Events.dialog_finished
		#Events.request_show_dialog.emit("You're welcome.", ELIZABETH_CHARACTER)
		#await Events.dialog_finished
