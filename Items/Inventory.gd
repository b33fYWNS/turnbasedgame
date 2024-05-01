extends Resource
class_name Inventory

@export var items : Array  [Resource]

signal item_added(item_index,item)
signal item_changed(item_index,item)
signal item_removed(item_index)

func add_item(item : Item, amount : int = 1)->void:
	var item_index = items.find(item)
	if item_index == -1:
		items.append(item)
		item.amount = amount
		item_added.emit(item_index, item)
	else:
		items[item_index].amount += amount
		item_changed.emit(item_index,item)
		
func remove_item(item : Item, amount : int = 1) -> Item:
	var item_index = items.find(item)
	if item_index == -1: return null
	
	item.amount -= amount
	item_changed.emit(item_index,item)
	if item.amount <= 0:
		items.erase(item)
		item_removed.emit(item_index)
	return item
