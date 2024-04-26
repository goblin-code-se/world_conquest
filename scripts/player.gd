"""
Objects used for storing state of each player
"""
class_name Player

var _id: int
var _troops: int
var _cards: Array
var _conquered_one: bool = false
var _initial_troop_hand: int
var trade_sets = []

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

func decrement_player_troops(i: int) -> void:
	_troops -=i

"""
Card logic
"""

func add_card(card):
	_cards.append(card)

func has_conquered() -> bool:
	if _conquered_one == true:
		return true # throughout heaven and earth, i alone am the conquered one
	else:
		return false

func reset_conquest():
	_conquered_one = false #reset at the end of each turn

func get_cards() -> Array:
	return _cards

func can_trade():
	if count_tradeable_sets().size() > 0:
		return true
	else: return false


func count_tradeable_sets() -> Array:
	var card_indices = {"infantry": [], "cavalry": [], "artillery": [], "wild": []}
	# Organize cards by type and collect indices
	for i in range(_cards.size()):
		var card = _cards[i]
		card_indices[card['symbol']].append(i)
		
	# Check for one of each type
	while card_indices['infantry'].size() > 0 and card_indices['cavalry'].size() > 0 and card_indices['artillery'].size() > 0:
		trade_sets.append([
			card_indices['infantry'].pop_front(),
			card_indices['cavalry'].pop_front(),
			card_indices['artillery'].pop_front()
			])
	
	# Check for sets of three
	for symbol in card_indices.keys():
		while card_indices[symbol].size() >= 3:
			trade_sets.append([
				card_indices[symbol].pop_front(),
				card_indices[symbol].pop_front(),
				card_indices[symbol].pop_front()
				])
	
	# Check for wild card sets
	while card_indices['wild'].size() > 0 and (card_indices['infantry'].size() > 1 or card_indices['cavalry'].size() > 1 or card_indices['artillery'].size() > 1):
		var used_cards = [card_indices['wild'].pop_front()]
		var added = false
		for symbol in ['infantry', 'cavalry', 'artillery']:
			if card_indices[symbol].size() > 1:
				used_cards.append(card_indices[symbol].pop_front())
				used_cards.append(card_indices[symbol].pop_front())
				trade_sets.append(used_cards)
				added = true
				break
		if not added:
			card_indices['wild'].insert(0, used_cards[0]) # Return the wild card if not used
	
	return trade_sets



func trading_set_used() -> void:
	var indices_to_remove = []
	for trade_set in trade_sets:
		indices_to_remove += trade_set
	
	indices_to_remove.sort_custom(sort_desc)
	for index in indices_to_remove:
		_cards.remove_at(index)

func count_bonus_troops(board: Board) -> int:
	return max(3, self.get_owned(board).size() / 3) + get_bonuses()

# TODO: get total bonus to add on top of player troop incrementation
func get_bonuses() -> int:
	var bonus = 0
	return bonus

func sort_desc(a, b):
	return b - a
