"""
Queue used for ordering of turns implemented with array
Array contains Player objects
"""
class_name TurnTracker

var _players: Array[Player]
var _pointer: int

func _init(arr: Array[Player]):
	_players = arr
	_pointer = 0

func peek() -> Player:
	return _players[_pointer]

func next() -> Player:
	_pointer = (_pointer + 1) % 5 # Wraparound logic for iteration over queue
	return _players[_pointer]

