extends Node
class_name Ai

var _id: int
var _troops: int
var _cards: Array
var _conquered_one: bool = false
var _initial_troop_hand: int
var trade_sets = []
var traded_cards = []
var indices_to_remove = []
var owned: Array[Territory] = []
var mission = null 
#var territory_in_card_owned:bool = false

func _init(id: int, initial_troops:int):
	_id = id
	_cards = []
	_initial_troop_hand = initial_troops
	
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

func move(board: Board) -> void:
	var most_dangerous_position: Territory
	var highest_danger_level: int
	for territory: Territory in get_owned(board):
		var danger_level = -territory.get_troop_number()
		var movable_to = false
		var neighbour
		for neighbour_id in board.graph.get_adjacent_nodes(territory.get_id()):
			neighbour = board.graph.get_node(neighbour_id)
			if neighbour.get_ownership() != territory.get_ownership():
				movable_to = true
				danger_level += neighbour.get_troop_number()
		if movable_to and (most_dangerous_position or danger_level > highest_danger_level):
			highest_danger_level = danger_level
			most_dangerous_position = territory

	var most_spare_troops: Territory
	for territory in board.graph.dfs(most_dangerous_position):
		var movable_from = true
		var neighbour
		for neighbour_id in board.graph.get_adjacent_nodes(territory.get_id()):
			neighbour = board.graph.get_node(neighbour_id)
			if neighbour.get_ownership() != territory.get_ownership():
				movable_from = false
		if movable_from and neighbour.get_troop_number() > most_spare_troops.get_troop_number():
			most_spare_troops = neighbour

	if most_spare_troops and most_dangerous_position:
		get_parent().handle_moving_from(most_spare_troops)
		get_parent().handle_moving_to(most_dangerous_position)
	else:
		get_parent().skip_stage()

func place_troops(board: Board):
	while get_parent().troops_to_add:
		var most_dangerous_position: Territory
		var highest_danger_level: int
		for territory: Territory in get_owned(board):
			var danger_level = -territory.get_troop_number()
			var movable_to = false
			var neighbour
			for neighbour_id in board.graph.get_adjacent_nodes(territory.get_id()):
				neighbour = board.graph.get_node(neighbour_id)
				if neighbour.get_ownership() != territory.get_ownership():
					movable_to = true
					danger_level += neighbour.get_troop_number()
			if movable_to and (most_dangerous_position or danger_level > highest_danger_level):
				highest_danger_level = danger_level
				most_dangerous_position = territory

		get_parent().handle_adding(most_dangerous_position)

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

	if not free_nodes:
		get_parent().handle_initial_adding(adjacent_to_enemies.pick_random())
		return

	var most_endangered_territories = []
	var highest_danger_level = null
	for node in adjacent_to_enemies:
		var danger_level = -node.get_troop_number()
		for neighbour in board.graph.get_adjacent_nodes(node.get_id()):
			if board.graph.get_node(neighbour).get_ownership() != self:
				danger_level += board.graph.get_node(neighbour).get_troop_number()
		if danger_level == highest_danger_level:
			most_endangered_territories.append(node)
		elif danger_level > highest_danger_level:
			highest_danger_level = danger_level
			most_endangered_territories = [node]

	get_parent().handle_initial_adding(most_endangered_territories.pick_random())

func attack(board: Board):
	var free_troops = []

	for node in get_owned_duplicated(board):
		var adjacent_troops = 0
		for neighbour in board.graph.get_adjacent_nodes(node.get_id()):
			if board.graph.get_node(neighbour).get_ownership() != self:
				adjacent_troops += board.graph.get_node(neighbour).get_troop_number()
		if node.get_troop_number() - adjacent_troops >= 3:
			free_troops.append(node)

	if not free_troops:
		get_parent().skip_stage()
		return

	var attacker = free_troops.pick_random()
	var attacked

	for neighbour in board.graph.get_adjacent_nodes(attacker.get_id()):
		if board.graph.get_node(neighbour).get_ownership() != attacker.get_ownership() \
		 and board.graph.get_node(neighbour)._continent == attacker._continent:
			attacked = board.graph.get_node(neighbour)
			break

	if not attacked:
		var attackables = []
		for neighbour in board.graph.get_adjacent_nodes(attacker.get_id()):
			if board.graph.get_node(neighbour).get_ownership() != attacker.get_ownership():
				attackables.append(board.graph.get_node(neighbour))
		attacked = attackables.pick_random()
	
	get_parent().handle_selecting_attacker(attacker)
	get_parent().handle_select_attacked(attacked)

func move_post_attack(board: Board, attacker: Territory, attacked: Territory):
	for neighbour in board.graph.get_adjacent_nodes(attacker.get_id()):
		if board.graph.get_node(neighbour).get_ownership() != attacker.get_ownership():
			get_parent().skip_stage()
			return

	get_parent().handle_moving_post_attack(attacked)
