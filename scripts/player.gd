"""
Objects used for storing state of each player
"""
class_name Player

var _id: int
var _troops: int
var _cards: Array
var _conquered_one: bool = false
var sets: int = 0
var _initial_troop_hand: int

func _init(id: int, initial_troops:int):
	_id = id
	_cards = []
	_initial_troop_hand = initial_troops
	
func get_owned(board: Board) -> Array[Territory]:
	return board.graph.get_nodes().filter(func(territory: Territory): territory.get_ownership() == self)
	
func get_troops() -> int:
	return _troops

func get_id() -> int:
	return _id

func increment_troops(i: int) -> void:
	_troops += i

"""
Rick!
"""

func add_card(card):
	_cards.append(card)

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

func count_bonus_troops(board: Board) -> int:
	return max(3, self.get_owned(board).size() / 3) + get_bonuses()

# TODO: get total bonus to add on top of player troop incrementation
func get_bonuses() -> int:
	var bonus = 0
	return bonus
