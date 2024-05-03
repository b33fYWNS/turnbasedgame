extends Resource
class_name TurnManager

enum {ALLY_TURN, ENEMY_TURN}

		
signal turn_started(battle_unit)

var turn: int = ALLY_TURN:
	get:
		return turn
	set(value):
		turn = value
				
var active_battle_unit : BattleUnit

func _on_async_turn_pool_turn_over() -> void:
	match turn:
		ALLY_TURN:
			self.turn = ENEMY_TURN
		ENEMY_TURN:
			self.turn = ALLY_TURN
	start_next_turn()

func add_battle_unit(battle_unit: BattleUnit) -> void:
	ReferenceStash.asyncTurnPool.add_battle_unit(battle_unit)

func remove_battle_unit(battle_unit: BattleUnit) -> void:
	ReferenceStash.asyncTurnPool.remove_battle_unit(battle_unit)

func start_next_turn() -> void:
	print("TurnManager: start_next_turn() called")
	var next_battle_unit = ReferenceStash.asyncTurnPool.get_next_active_node()
	if next_battle_unit:
		active_battle_unit = next_battle_unit
		print("TurnManager: active_battle_unit set to", active_battle_unit)
		turn_started.emit(active_battle_unit)
	else:
		print("TurnManager: no more active battle units")
		pass
		
func on_battle_unit_turn_finished(battle_unit: BattleUnit) -> void:
	print("TurnManager: battle_unit_turn_finished() called for", battle_unit)
	ReferenceStash.asyncTurnPool.add_battle_unit(battle_unit)
	start_next_turn()
