"""
Objects used for storing state of each player
"""
class_name Player

var _id: int
var _troops: int

func _init(id: int, troops:int):
	_id = id
	_troops = troops

