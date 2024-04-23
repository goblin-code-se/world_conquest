"""
Objects used for storing state of each player
"""
class_name Player

var _id: int
var _troops: int
var _owned_territories: Array
var _cards: Array
var _conquered_one: bool = false

func _init(id: int, troops:int):
	_id = id
	_troops = troops
	_owned_territories = []
	_cards = []

func get_owned() -> Array:
	return _owned_territories
	
func get_troops() -> int:
	return _troops

func get_id() -> int:
	return _id

func increment_troops(i: int) -> void:
	_troops += i

func decrement_troops(i: int) -> void:
	_troops -= i

func add_territory(territory):
	_owned_territories.append(territory)
	_conquered_one = true

func add_card(card):
	_cards.append(card)

func remove_territory(territory):
	_owned_territories.erase(territory)

func has_conquered() -> bool:
	if _conquered_one == true:
		return true # throughout heaven and earth, i alone am the conquered one
	else:
		print("why tf this not working")
		return false

func reset_conquest():
	_conquered_one = false #reset at the end of each turn

func get_cards() -> Array:
	return _cards
