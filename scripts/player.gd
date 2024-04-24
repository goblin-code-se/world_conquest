"""
Objects used for storing state of each player
"""
class_name Player

var _id: int
var _troops: int
var _initial_troop_hand: int

func _init(id: int, initial_troops:int):
	_id = id
	_initial_troop_hand = initial_troops
	
func get_owned(board: Board) -> Array[Territory]:
	return board.graph.get_nodes().filter(func(territory: Territory): territory.get_ownership() == self)
	
func get_troops() -> int:
	return _troops

func get_id() -> int:
	return _id

func increment_troops(i: int) -> void:
	_troops += i


func count_bonus_troops(board: Board) -> int:
	return max(3, self.get_owned(board).size() / 3) + get_bonuses()

# TODO: get total bonus to add on top of player troop incrementation
func get_bonuses() -> int:
	var bonus = 0
	return bonus
