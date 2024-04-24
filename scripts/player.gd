"""
Objects used for storing state of each player
"""
class_name Player

var _id: int
var _troops: int
var _owned_territories: Array
var _cards: Array
var _conquered_one: bool = false
var sets: int = 0

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

"""
Rick!
"""

func decrement_troops(i: int) -> void:
	_troops -= i

func add_territory(territory):
	_owned_territories.append(territory)

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

func can_trade():
	if count_tradeable_sets() > 0:
		return true
	else: return false

func count_tradeable_sets():
	var infantry = 0
	var cavalry = 0
	var artillery = 0
	var wildcards = 0
	
	for card in _cards:
		match card['symbol']:
			"infantry":
				infantry += 1
			"cavalry":
				cavalry += 1
			"artillery":
				artillery += 1
			"wild":
				wildcards += 1

	
	while wildcards > 0 and (infantry > 1 or cavalry > 1 or artillery > 1):
		if infantry > 1:
			sets += 1
			infantry -= 2
			wildcards -= 1
		elif cavalry > 1:
			sets += 1
			cavalry -= 2
			wildcards -= 1
		elif artillery > 1:
			sets += 1
			artillery -= 2
			wildcards -= 1
			
	while infantry > 0 and cavalry > 0 and artillery > 0:
		sets += 1
		infantry -= 1
		cavalry -= 1
		artillery -= 1
		
	# Calculate sets of three of a kind
	while infantry >= 3:
		sets += 1
		infantry -= 3
	while cavalry >= 3:
		sets += 1
		cavalry -= 3
	while artillery >= 3:
		sets += 1
		artillery -= 3
	
	return sets

func trading_set_used() -> void:
	sets -=1
