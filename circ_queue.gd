"""
Queue used for ordering of turns implemented with array
Array contains Player objects
"""
class_name Queue

var _players: Array[Player]

func _init():
	_players = []

func enqueue(item: Player):
	_players.push_back(item)

func dequeue() -> Player:
	return _players.pop_front()

func peek() -> Player:
	return _players.front()
