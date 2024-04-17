"""
Objects used for storing state of each player
"""
class_name Player

var _id: int
var _troops: int
var _owned_territories: Array

func _init(id: int, troops:int):
	_id = id
	_troops = troops
	_owned_territories = []
	
func get_owned() -> Array:
	return _owned_territories
	
func get_troops() -> int:
	return _troops

func get_id() -> int:
	return _id

func increment_troops(i: int) -> void:
	_troops += i
