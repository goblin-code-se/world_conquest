"""
Queue used for ordering of turns implemented with array
"""
class_name TurnTracker

var _players
var _pointer: int

func _init(arr):
	_players = arr
	_pointer = 0
	
func peek():
	return _players[_pointer]

func next():
	_pointer = (_pointer + 1) % 5 # Wraparound logic for iteration over queue
	return _players[_pointer]

func get_all():
	return _players
