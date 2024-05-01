extends MarginContainer
class_name OverworldMenuManager

#############
## VARIABLES
#############


var stats : PlayerClassStats = ReferenceStash.elizabethStats
var inventory : Inventory = ReferenceStash.inventory
var item_resource : Item
var uiStack := UIStack.new()

@onready var over_world_menu : FocusMenu = %OverWorldMenu
@onready var elizabeth_stats : ElizabethStats = %ElizabethStats
@onready var item_list : FocusMenu = %ItemList
@onready var context_menu : FocusMenu = %ContextMenu
@onready var info_menu : FocusMenu = %InfoMenu
@onready var timer : Timer = $Timer
@onready var healing_sfx = $HealingSFX

#############
## OVERRIDES
#############
func _ready() -> void:
	over_world_menu.hide()
	Events.request_show_overworld_menu.connect(_on_request_show_overworld_menu)
	
func use_healing_item(item : HealingItem) -> void:
	set_process_unhandled_input(false)
	uiStack.pop()
	uiStack.pop()
	uiStack.push(elizabeth_stats)
	inventory.remove_item(item)
	stats.health += item.heal_amount
	healing_sfx.play()
	await elizabeth_stats.animation_finished
	timer.start(.5)
	await timer.timeout
	uiStack.pop()
	uiStack.push(item_list)
	set_process_unhandled_input(true)
	
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not uiStack.empty():
			uiStack.pop()
			if uiStack.empty():
				get_viewport().set_input_as_handled()
				get_tree().paused = false
			
###########
## METHODS
###########

#####################
## SIGNALS CALLBACKS
#####################

func _on_request_show_overworld_menu() -> void:
	uiStack.push(over_world_menu)
	get_tree().paused = true


func _on_over_world_menu_option_selected(option : int):
	match option:
		OverworldMenu.OverworldMenuOption.STATS:
			uiStack.push(elizabeth_stats)
		OverworldMenu.OverworldMenuOption.ITEMS:
			uiStack.push(item_list)
		OverworldMenu.OverworldMenuOption.SAVE:
			get_viewport().set_input_as_handled()
			SaveManager.save_game()
			uiStack.pop()
			Events.request_show_message.emit("Game Saved")
		OverworldMenu.OverworldMenuOption.LOAD:
			get_viewport().set_input_as_handled()
			get_tree().paused = false
			SaveManager.load_game()
		OverworldMenu.OverworldMenuOption.EXIT:
			uiStack.pop()
			get_tree().paused = false
			
func _on_item_list_resource_selected(resource : Item) -> void:
	item_resource = resource
	uiStack.push(context_menu)
	
func _on_context_menu_option_selected(option : int):
	match option:
		context_menu.CONTEXT_OPTION.USE:
			if item_resource is HealingItem:
				if stats.health < stats.max_health:
					use_healing_item(item_resource)
				else:
					info_menu.text = "Health at full."
					uiStack.push(info_menu)
		context_menu.CONTEXT_OPTION.INFO:
			info_menu.text = item_resource.description
			uiStack.push(info_menu)
