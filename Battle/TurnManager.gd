extends Resource
class_name TurnManager

enum {ALLY_TURN, ENEMY_TURN}

		
signal ally_turn_started()
signal ally_turn_ended()
signal enemy_turn_started()

var turn: int = ALLY_TURN:
	get:
		return turn
	set(value):
		
		turn = value
		match turn:
			ALLY_TURN:
				ally_turn_started.emit()
			ENEMY_TURN:
				ally_turn_ended.emit()
				enemy_turn_started.emit()

func start() -> void:
	self.turn = ALLY_TURN
	
func advance_turn() -> void:
	self.turn = int(self.turn+1)&1
