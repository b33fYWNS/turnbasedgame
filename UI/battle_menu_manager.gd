extends Control

const RUN_BATTLE_ACTION = preload("res://BattleActions/RunBattleAction.tres")

var elizabethStats : PlayerClassStats = ReferenceStash.elizabethStats
var inventory : Inventory = ReferenceStash.inventory

var uiStack := UIStack.new()

var selected_resource : Resource

@onready var battle_menu = %BattleMenu
@onready var action_list = %ActionList
@onready var item_list = %ItemList
@onready var context_menu = %ContextMenu
@onready var info_menu = %InfoMenu

signal battle_menu_resource_selected(selected_resource: Resource)

func _ready() -> void:
	action_list.hide()
	item_list.hide()
	action_list.fill(elizabethStats.battle_actions)
	
func show_battle_menu()->void:
	await battle_menu.show_menu()
	uiStack.push(battle_menu)
	
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and uiStack.uis.size()>1:
		uiStack.pop()


func _on_battle_menu_menu_option_selected(option:int):
	match option:
		BattleMenu.ACTION:
			uiStack.push(action_list)
		BattleMenu.ITEM:
			uiStack.push(item_list)
		BattleMenu.RUN:
			battle_menu.hide_menu()
			battle_menu.release_menu_focus()
			battle_menu_resource_selected.emit(RUN_BATTLE_ACTION)
			



func _on_action_list_resource_selected(resource: BattleAction):
	uiStack.push(context_menu)
	selected_resource = resource
	
 # Replace with function body.


func _on_item_list_resource_selected(resource: Item):
	uiStack.push(context_menu)
	selected_resource = resource
	



func _on_context_menu_option_selected(option:int) -> void:
	match option:
		ContextMenu.CONTEXT_OPTION.USE:
			uiStack.pop()
			uiStack.pop()
			battle_menu.release_focus()
			battle_menu.hide_menu()
			if selected_resource is Item:
				inventory.remove_item(selected_resource)
			battle_menu_resource_selected.emit(selected_resource)
		
		ContextMenu.CONTEXT_OPTION.INFO:
			if selected_resource is Item or selected_resource is BattleAction:
				info_menu.text = selected_resource.description
				uiStack.push(info_menu)
