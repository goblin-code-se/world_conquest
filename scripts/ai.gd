extends Node
class_name Ai

var _parent
var _id: int
var _troops: int
var _name: String
var _cards: Array
var _conquered_one: bool = false
var _initial_troop_hand: int
var trade_sets = []
var traded_cards = []
var indices_to_remove = []
var owned: Array[Territory] = []
var mission = null
var _difficulty: float
var timer
#var territory_in_card_owned:bool = false

func _init(id: int, initial_troops:int, difficulty: float, parent):
	_id = id
	_cards = []
	_initial_troop_hand = initial_troops
	_difficulty = difficulty
	_parent = parent
	
func get_owned(board: Board) -> Array[Territory]:
	return board.graph.get_nodes().filter(func(territory: Territory): territory.get_ownership() == self)
	
""""
This duplication is, as of now, on purpose.
"""

func get_out_of_owned(territory: Territory) -> void:
	owned.erase(territory)

func get_owned_duplicated(board: Board) -> Array[Territory]:
	for territory in board.graph.get_nodes():
		if territory.get_ownership() == self and territory not in owned:
			owned.append(territory)
	return owned
	
func get_troops() -> int:
	return _troops

func get_id() -> int:
	return _id

func increment_troops(i: int) -> void:
	_troops += i

func decrement_player_troops(i: int) -> void:
	_troops -= i

"""
Card logic
"""

func add_card(card):
	_cards.append(card)

func has_conquered() -> bool:
	return _conquered_one

func reset_conquest():
	_conquered_one = false #reset at the end of each turn

func get_cards() -> Array:
	return _cards

func can_trade():
	return count_tradeable_sets().size() > 0

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
	
	print("the trade sets are: ", trade_sets)
	return trade_sets

func trading_set_used(territory_cards: Array, board: Board) -> void:
	var cards_to_check_ownership = []
	for trade_set in trade_sets:
		indices_to_remove += trade_set
	
	
	indices_to_remove.sort()
	indices_to_remove.reverse()
	
	print("The indices to remove are: ", indices_to_remove)
	
	for index in indices_to_remove:
		print("the traded cards are: ", _cards[index])
		cards_to_check_ownership.append(_cards[index])
		territory_cards.append(_cards[index])
		_cards.remove_at(index)
	
	award_extra_troops_if_territory_owned(board, cards_to_check_ownership)
	
	indices_to_remove.clear()
	territory_cards.shuffle()
	traded_cards.clear()
	print("at this moment, the traded_sets still are: ", trade_sets)
	trade_sets.clear()
	
	print("deck size after returning cards: ", territory_cards.size())

func count_bonus_troops(board: Board) -> int:
	return max(3,self.get_owned_duplicated(board).size()/3) # + get_bonuses()

"# TODO: get total bonus to add on top of player troop incrementation
func get_bonuses() -> int:
	var bonus = 0
	return bonus"

func sort_desc(a, b):
	return b - a

func award_extra_troops_if_territory_owned(board: Board, traded_cards: Array) -> void:
	var owned_territories = get_owned_duplicated(board)
	var territories_to_award = [] 
	
	print(owned_territories)
	
	for card in traded_cards:
		for territory in owned_territories:
			if territory.get_name() == card["name"]:
				territories_to_award.append(territory)
	
	#print(territories_to_award)
	
	if territories_to_award.size():
		var random_index = randi_range(0, territories_to_award.size() - 1)
		var selected_territory = territories_to_award[random_index]
		selected_territory.increment_troops(2)
		print("Added 2 extra troops to ", selected_territory.get_name())

func assign_mission(mission_card):
	mission = mission_card
	print("Mission assigned to player %d: %s" % [self.get_id(), mission.description])

func get_mission():
	return mission

func move(board: Board) -> bool:
	print("SANITY CHECK :)")
	if randf() < _difficulty:
		print("i am going to fuck up now")
		var territories_with_extra_troops = []
		for territory in get_owned_duplicated(board):
			if territory.get_troop_number() > 1:
				territories_with_extra_troops.append(territory)
		if territories_with_extra_troops.is_empty():
			return true

		var to_move_from = territories_with_extra_troops.pick_random()
		var troops_to_move = randi_range(1, to_move_from.get_troop_number() - 1)
		if board.graph.all_connected_territories(to_move_from).is_empty():
			return true
		var to_move_to = board.graph.all_connected_territories(to_move_from).pick_random()

		if to_move_from and to_move_to:
			print(_name, " is moving from ", to_move_from.get_name())
			print(" to ", to_move_to.get_name())
			_parent.handle_moving_from(to_move_from)
			for i in range(to_move_from.get_troop_number() - 1):
				_parent.handle_moving_to(to_move_to)
		else:
			#_parent.next_turn()
			return true
		
		if randf() < _difficulty:
			#_parent.next_turn()
			return true

		return false

	var movable_to = []
	for territory: Territory in get_owned_duplicated(board):
		var neighbour
		for neighbour_id in board.graph.get_adjacent_nodes(territory.get_id()):
			neighbour = board.graph.get_node(neighbour_id)
			# print(neighbour.get_ownership().get_id(), " ", territory.get_ownership().get_id())
			if neighbour.get_ownership() != territory.get_ownership():
				movable_to.append(territory)
				break
	
	if movable_to.is_empty():
		return true
	var to = movable_to.pick_random()
	
	var movable_from = []
	for territory in board.graph.all_connected_territories(to):
		var can_move_from = true
		var neighbour
		for neighbour_id in board.graph.get_adjacent_nodes(territory.get_id()):
			neighbour = board.graph.get_node(neighbour_id)
			if neighbour.get_ownership() != territory.get_ownership():
				can_move_from = false
		if can_move_from:
			movable_from.append(territory)
			
	if movable_from.is_empty():
		return true
	
	var from = movable_from.pick_random()

	print(_name + " is moving from " + from.get_name() + " to " + to.get_name())
	_parent.handle_moving_from(from)
	for i in range(from.get_troop_number() - 1):
			_parent.handle_moving_to(to)

	return true

func place_troops(board: Board, troops_to_add: int):
	if troops_to_add > 0:
		
		if randf() < _difficulty:
			if get_owned_duplicated(board).is_empty():
				return
			_parent.handle_adding(get_owned_duplicated(board).pick_random())
			return
		
		var most_dangerous_position: Territory
		var highest_danger_level: int
		for territory: Territory in get_owned_duplicated(board):
			var danger_level = -territory.get_troop_number()
			var movable_to = false
			var neighbour
			for neighbour_id in board.graph.get_adjacent_nodes(territory.get_id()):
				neighbour = board.graph.get_node(neighbour_id)
				print(neighbour.get_ownership().get_id(), " ", territory.get_ownership().get_id())
				if neighbour.get_ownership() != territory.get_ownership():
					movable_to = true
					#print("movable to !")
					danger_level += neighbour.get_troop_number()
			if movable_to and (most_dangerous_position == null or danger_level > highest_danger_level):
				highest_danger_level = danger_level
				most_dangerous_position = territory
		print("PLACING UNIT AT: " + most_dangerous_position.get_name())
		_parent.handle_adding(most_dangerous_position)
	else:
		_parent.skip_stage()

func initial_adding(board: Board):
	var free_nodes = []

	for node in board.graph.get_nodes():
		if node.get_ownership() == null:
			free_nodes.append(node)

	var adjacent_to_enemies = []
	for node in get_owned_duplicated(board):
		for neighbour in board.graph.get_adjacent_nodes(node.get_id()):
			if board.graph.get_node(neighbour).get_ownership() != self and node not in adjacent_to_enemies:
				adjacent_to_enemies.append(node)

	if free_nodes.size() == 0:
		if randf() < _difficulty:
			_parent.handle_initial_adding(get_owned_duplicated(board).pick_random())
		else:
			var most_endangered_territories = []
			var highest_danger_level = null
			for node in adjacent_to_enemies:
				var danger_level = -node.get_troop_number()
				for neighbour in board.graph.get_adjacent_nodes(node.get_id()):
					if board.graph.get_node(neighbour).get_ownership() != self:
						danger_level += board.graph.get_node(neighbour).get_troop_number()
				if danger_level == highest_danger_level:
					most_endangered_territories.append(node)
				elif highest_danger_level == null or danger_level > highest_danger_level:
					highest_danger_level = danger_level
					most_endangered_territories = [node]

			_parent.handle_initial_adding(most_endangered_territories.pick_random())
		return

	if randf() < _difficulty:
		_parent.handle_initial_adding(free_nodes.pick_random())
		return
	
	var adjacent_to_allies = []
	var continents = []
	var in_owned_continent = []
	var both = []
	for node in free_nodes:
		continents.append(node.get_continent())

	for node in free_nodes:
		for neighbour_id in board.graph.get_adjacent_nodes(node.get_id()):
			var neighbour = board.graph.get_node(neighbour_id)
			if neighbour.get_ownership() == self:
				adjacent_to_allies.append(node)
				continue
			if neighbour.get_continent() in continents:
				in_owned_continent.append(node)
				continue
			if neighbour in in_owned_continent and neighbour in adjacent_to_allies:
				both.append(node)
				continue
	
	if both:
		_parent.handle_initial_adding(both.pick_random())
	elif in_owned_continent:
		_parent.handle_initial_adding(in_owned_continent.pick_random())
	elif adjacent_to_allies:
		_parent.handle_initial_adding(adjacent_to_allies.pick_random())
	else:
		_parent.handle_initial_adding(get_owned_duplicated(board).pick_random())

func attack(board: Board):
	var free_troops = []
	
	if randf() < _difficulty:
		for node in get_owned_duplicated(board):
			if node.get_troop_number() > 1:
				for neighbour_id in board.graph.get_adjacent_nodes(node.get_id()):
					if board.graph.get_node(neighbour_id).get_ownership() != self:
						free_troops.append(node)
						break

		if free_troops.is_empty():
			_parent.skip_stage()
			return

		var attacker = free_troops.pick_random()

		var adjacent_enemies = []
		for node_id in board.graph.get_adjacent_nodes(attacker.get_id()):
			if board.graph.get_node(node_id).get_ownership() != self:
				adjacent_enemies.append(board.graph.get_node(node_id))
		var attacked = adjacent_enemies.pick_random()
		_parent.handle_selecting_attacker(attacker)
		_parent.handle_select_attacked(attacked)
		return

	for node in get_owned_duplicated(board):
		for neighbour in board.graph.get_adjacent_nodes(node.get_id()):
			if board.graph.get_node(neighbour).get_ownership().get_id() != get_id():
				print("ATTACK: ", node.get_troop_number(), "-", board.graph.get_node(neighbour).get_troop_number(), "=", node.get_troop_number() - board.graph.get_node(neighbour).get_troop_number(), ">= 3: ", node.get_troop_number() - board.graph.get_node(neighbour).get_troop_number() >= 3)
				if node.get_troop_number() - board.graph.get_node(neighbour).get_troop_number() >= 3:
					free_troops.append(node)
	
	if free_troops.is_empty():
		print("ATTACK: free troops more like free goops amirite hahahaha")
		_parent.skip_stage()
		return

	var attacker = free_troops.pick_random()
	var attackable = []

	for neighbour in board.graph.get_adjacent_nodes(attacker.get_id()):
		if board.graph.get_node(neighbour).get_ownership() != attacker.get_ownership() \
		 and board.graph.get_node(neighbour).get_continent() == attacker.get_continent() \
		 and board.graph.get_node(neighbour).get_troop_number() <= attacker.get_troop_number() + 5:
			attackable.append(board.graph.get_node(neighbour))
	
	if attackable.is_empty():
		print("ATTACK: Fool me once")
		for neighbour in board.graph.get_adjacent_nodes(attacker.get_id()):
			if board.graph.get_node(neighbour).get_ownership() != attacker.get_ownership():
				attackable.append(board.graph.get_node(neighbour))
	print("ATTACK: Shame on you")
	if attackable.is_empty():
		print("ATTACK: Fool me twice")
		_parent.skip_stage()
		return
	
	var attacked = attackable.pick_random()
	
	if null in [attacker, attacked]:
		_parent.skip_stage()
		return
	print("ATTACK: Shame on you")
	_parent.handle_selecting_attacker(attacker)
	_parent.handle_select_attacked(attacked)

func move_post_attack(board: Board, attacker: Territory, attacked: Territory):
	if randf() < _difficulty:
		_parent.handle_moving_post_attack(attacked)
	
	for neighbour in board.graph.get_adjacent_nodes(attacker.get_id()):
		if board.graph.get_node(neighbour).get_ownership() != attacker.get_ownership():
			_parent.skip_stage()
			return

	_parent.handle_moving_post_attack(attacked)
