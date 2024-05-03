extends Resource
class_name AsyncTurnPool

var active_nodes : Array[BattleUnit] = []
var stats : ClassStats

signal turn_over

func add_battle_unit(battle_unit: BattleUnit) -> void:
	active_nodes.append(battle_unit)
	sort_active_nodes()
	
func remove_battle_unit(battle_unit: BattleUnit) -> void:
	if active_nodes.is_empty(): return
	active_nodes.erase(battle_unit)
	if active_nodes.is_empty(): emit_signal("turn_over")
	
func sort_active_nodes() -> void:
	active_nodes = active_nodes.filter(func(node): return is_instance_valid(node))
	active_nodes.sort_custom(func(a, b): return a.stats.speed > b.stats.speed)
	
func get_next_active_node() -> BattleUnit:
	if active_nodes.is_empty():
		print("AsyncTurnPool: no active nodes")
		return null
	var next_node = active_nodes.pop_front()
	print("AsyncTurnPool: next active node is", next_node)
	return next_node
