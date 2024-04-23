extends Node

var current_game_state: GameState
var current_player: Player
var attacking_territory
var defender_territory
var adjacent_territories
var board_graph: Graph
var edges: Array
var moving_from: Territory
var moving_to: Territory
var continent_bonuses: Dictionary
var players: Array[Player]
var turn_number: int
var Mission_mode: bool
var territory_cards = []

@onready var board = $Board

enum GameState {
	SELECT_ATTACKER,
	SELECT_ATTACKED,
	ADDING_TROOPS,
	ATTACK,
	MOVING_FROM,
	MOVING_TO,
	INITIAL_STATE
}
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_territory_cards()
	print(territory_cards.size())
	turn_number = 0
	players = []
	for i in range(5):
		players.append(Player.new(i+1, 25))
	current_player = players[0]
	current_game_state = GameState.INITIAL_STATE
	$Ui.update_game_state("INITIAL STATE")
	board_graph = $Board_Main.graph
	edges = board_graph.get_edges()
	if Mission_mode == true:
		assign_mission_cards_to_players(players)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

"""Rick!"""
# var current_game_state = GameState.SELECT_ATTACKER # This shouldn't be left like that
# Recommendation: In _ready() specify the game state at every state. There should be a general "do nothing" state and be changed for ATTACK when, welp, ATTACKing
# Also, these ATTACKing/defender could be added to the ATTACK() function, and just call it when, WELP, ATTACKing, so it re-starts
#Also, probably a more descriptive name would be populate_adjacent_list or something like that

func attack(attacking_territory: Territory, defender_territory: Territory):
	var attacker_losses = 0
	var defender_losses = 0
	var attacker_dice_count = min(3, attacking_territory.get_troop_number() -1)
	var defender_dice_count = min(2, defender_territory.get_troop_number())
	var defender = defender_territory.get_ownership()
	var attack_dice = []
	for i in range(attacker_dice_count):
		attack_dice.append(randi() % 6 +1)
	attack_dice.sort()
	attack_dice.reverse()
	
	var defense_dice = []
	for i in range(defender_dice_count):
		defense_dice.append(randi() % 6 +1)
	defense_dice.sort()
	defense_dice.reverse()
	
	for i in range(min(attack_dice.size(), defense_dice.size())):
		if attack_dice[i] > defense_dice[i]:
			defender_losses +=1
		else:
			attacker_losses +=1
	
	attacking_territory.decrement_troops(attacker_losses)
	defender_territory.decrement_troops(defender_losses)
	
	if defender_territory.get_troop_number() <= 0:
		print(defender_territory, "conquered")
		defender_territory.set_ownership(attacking_territory.get_ownership()) # this needs a method to get the conquered territory out of the owned territories of the attacked
		current_player.add_territory(defender_territory)
		attacking_territory.decrement_troops(attacker_dice_count)
		defender_territory.increment_troops(attacker_dice_count)


func end_of_turn_draw_card(player):
	if player.has_conquered():
		var card = draw_territory_card()
		player.add_card(card)
		print("Player", player.get_id(), "drew a card:", card.name)
		player.reset_conquest()

func setup_territory_cards():
	territory_cards = [
		{"name": "Alaska", "symbol": "infantry"},
		{"name": "Northwest Territory", "symbol": "artillery"},
		{"name": "Greenland", "symbol": "cavalry"},
		{"name": "Alberta", "symbol": "cavalry"},
		{"name": "Ontario", "symbol": "cavalry"},
		{"name": "Eastern Canada", "symbol": "cavalry"},
		{"name": "Western United States", "symbol": "artillery"},
		{"name": "Eastern United States", "symbol": "artillery"},
		{"name": "Central America", "symbol": "artillery"},
		{"name": "Venezuela", "symbol": "infantry"},
		{"name": "Peru", "symbol": "infantry"},
		{"name": "Brazil", "symbol": "artillery"},
		{"name": "Argentina", "symbol": "infantry"},
		{"name": "Iceland", "symbol": "infantry"},
		{"name": "Scandinavia", "symbol": "cavalry"},
		{"name": "Russia", "symbol": "cavalry"},
		{"name": "Great Britain", "symbol": "artillery"},
		{"name": "Northern Europe", "symbol": "artillery"},
		{"name": "Western Europe", "symbol": "artillery"},
		{"name": "Southern Europe", "symbol": "artillery"},
		{"name": "North Africa", "symbol": "cavalry"},
		{"name": "Egypt", "symbol": "infantry"},
		{"name": "East Africa", "symbol": "infantry"},
		{"name": "Central Africa", "symbol": "infantry"},
		{"name": "South Africa", "symbol": "artillery"},
		{"name": "Madagascar", "symbol": "cavalry"},
		{"name": "Ural", "symbol": "cavalry"},
		{"name": "Siberia", "symbol": "cavalry"},
		{"name": "Yakutsk", "symbol": "cavalry"},
		{"name": "Kamchatka", "symbol": "infantry"},
		{"name": "Irkutsk", "symbol": "cavalry"},
		{"name": "Mongolia", "symbol": "infantry"},
		{"name": "Japan", "symbol": "artillery"},
		{"name": "Afghanistan", "symbol": "cavalry"},
		{"name": "China", "symbol": "infantry"},
		{"name": "Middle East", "symbol": "infantry"},
		{"name": "India", "symbol": "cavalry"},
		{"name": "Southeast Asia", "symbol": "infantry"},
		{"name": "Indonesia", "symbol": "artillery"},
		{"name": "New Guinea", "symbol": "infantry"},
		{"name": "Western Australia", "symbol": "artillery"},
		{"name": "Eastern Australia", "symbol": "artillery"}
	]
	territory_cards.shuffle()



var mission_cards = [
	{"description": "Capture Europe, Australia and one other continent"},
	{"description": "Capture Europe, South America and one other continent"},
	{"description": "Capture North America and Africa"},
	{"description": "Capture Asia and South America"},
	{"description": "Capture North America and Australia"},
	{"description": "Capture 24 territories"},
	{"description": "Destroy all armies of a named opponent (if yourself, capture 24 territories)"},
	{"description": "Capture 18 territories and occupy each with two troops"}
]

func draw_territory_card():
	setup_territory_cards()
	print(territory_cards.size())
	if territory_cards.size() == 0:
		print("No more territory cards available")
		return territory_cards.pop_front()
	else:
		var card = territory_cards.pop_front()
		return card
	
func all_territories_owned():
	if board_graph.all_territories_owned():
		return true


# Only if mission game mode, lacks the signal.
func assign_mission_cards_to_players(players):
	mission_cards.shuffle()
	for player in players:
		var mission = mission_cards.pop_front() 
		player.assign_mission(mission)  # Lacks an assign mission function


func _on_attack_button_pressed() -> void:
	change_game_state(GameState.SELECT_ATTACKER)

func _on_move_button_pressed() -> void:
	change_game_state(GameState.MOVING_FROM)


"""
main state machine function, handling clicks based on current game state
"""
func _on_board_main_territory_clicked(which: Territory) -> void:
	var initial_troops_depleted: bool = false
	match current_game_state:
		GameState.ADDING_TROOPS:
			handle_adding(which)
		GameState.SELECT_ATTACKER:
			handle_selecting_attacker(which)
		GameState.SELECT_ATTACKED:
			handle_select_attacked(which)
		GameState.MOVING_FROM:
			handle_moving_from(which)
		GameState.MOVING_TO:
			handle_moving_to(which)
		GameState.INITIAL_STATE:
			handle_initial_adding(which)
				

func calculate_continent_bonus(player: Player):
	var bonus = 0
	continent_bonuses = {"North America": 5, 
						"South America": 2, 
						"Africa": 3, 
						"Europe": 5, 
						"Asia": 7, 
						"Australia": 2}
	for continent_name in continent_bonuses.keys():
		if board.player_controls_continent(player.get_id(), continent_name):
			bonus += continent_bonuses[continent_name]
		return bonus
	


"""John!"""

"""
checks if every node in the board belongs to one player id (game over)
 - returns -1 if no winner
 - returns player id of winner otherwise
"""

func is_game_over() -> int:
	var winner = board_graph.get_nodes()[0].get_ownership()
	for node in board_graph.get_nodes():
		if node.get_ownership() != winner:
			return -1
	return winner

"""
returns whether or not a move to and from two territories is valid
 - returns true if both territories are connected and belong to same player
 - returns false otherwise
"""
func valid_move(moving_from: Territory, moving_to: Territory) -> bool:
	var connected_nodes = board_graph.dfs(moving_from.get_id())
	if moving_to.get_ownership() == current_player.get_id() and moving_to.get_id() in connected_nodes:
		return true
	return false

"""
moves an amount of troops from one territory to the other
"""
func move(from: Territory, to: Territory, amount: int) -> void:
	# TODO: allow for multiple troops
	from.increment_troops(-amount)
	to.increment_troops(amount)
	
"""
handles specific rules of initial map population, passing off bulk to handle_adding()
"""
func handle_initial_adding(which: Territory) -> void:
	# Check if the territory clicked is either unowned or owned by the current player
	if which.get_ownership() == 0 or which.get_ownership() == current_player.get_id():
		handle_adding(which)
		if all_territories_owned() and current_player.get_troops() > 0:
			return
		next_turn()
	else:
		print("already owned.")


"""
checks whether an adding click is valid via:
	- same ownership as current player
	- whether it is a neutral faction (only happens at start)
		- if so changing ownership to that player
	- whether or not a player has more than 0 troops to add
		- if on 0, setting to next state of turn (SELECT_ATTACKER)
if valid deducts 1 from player troop count, and adds 1 troop to territory that was clicked
"""


func handle_adding(which: Territory) -> void:
	if which.get_ownership() == current_player.get_id() or which.get_ownership() == 0:
		if current_player.get_troops() > 0:
			print("Adding troops")
			which.increment_troops(1) # can add multiple at a time eventually to help with turns of huge amounts of troops
			current_player.increment_troops(-1)
			if which.get_ownership() == 0:
				which.set_ownership(current_player.get_id())
				current_player.add_territory(which)
	if current_player.get_troops() == 0 and current_game_state != GameState.INITIAL_STATE:
		change_game_state(GameState.SELECT_ATTACKER)

	$Ui.update_troop_count(current_player.get_troops())

		
"""
checks whether it is possible to attack from a territory, valid if:
	- it belongs to player clicking
"""
func handle_selecting_attacker(which: Territory) -> void:
	if which.get_ownership() == current_player.get_id():
		attacking_territory = which
		print("Attacker territory: ", which.get_id())
		change_game_state(GameState.SELECT_ATTACKED)
	else:
		print("not your territory bro")

func change_game_state(game_state: GameState):
	current_game_state = game_state
	$Ui.update_game_state(GameState.keys()[game_state])

"""
checks whether it is possible to attack a territory from a previous valid attacking territory via:
	- checking adjacency of a defender
	- territory doesn't belong to current player
"""
func handle_select_attacked(which: Territory):
	var adjacent: bool = which.get_id() in board_graph.get_adjacent_nodes(attacking_territory.get_id())
	if adjacent and which.get_ownership() != current_player.get_id(): #and which.get_ownership() != attacking_territory.get_ownership():
		defender_territory = which
		change_game_state(GameState.SELECT_ATTACKED)
		print("defender: ", which.get_id())
		attack(attacking_territory, defender_territory)
		change_game_state(GameState.SELECT_ATTACKER)
	else:
		print("can't attack")

"""
checks whether it is valid to move troops from a territory via:
	- belongs to current player
	- whether a move would leave atleast 1 troop in a territory (risk rules)
if valid, changes state to MOVING TO
"""
func handle_moving_from(which: Territory) -> void:
	if which.get_ownership() == current_player.get_id() and which.get_troop_number() > 1:
		moving_from = which
		change_game_state(GameState.MOVING_TO)
	else:
		print("not your territory")

"""
checks whether a move is valid via:
	- belongs to current player
	- running valid_move()
if valid:
	- runs move() to and from territories clicked
	- ends turn (risk rules)
if not valid:
	- changes state back to MOVING_FROM to allow for reattempt
"""
func handle_moving_to(which: Territory) -> void:
	if which.get_ownership() == current_player.get_id():
		moving_to = which
		if valid_move(moving_from, moving_to):
			print("valid movement")
			move(moving_from, moving_to, 1)
			# change_game_state(GameState.MOVING_FROM)
			next_turn()
		else:
			print("not reachable")
			change_game_state(GameState.MOVING_FROM)
	else:
		print("not your territory")

# TODO: get total bonus to add on top of player troop incrementation
func get_bonuses() -> int:
	var bonus = 0
	return bonus
	
"""
adds specified amount of troops to player based on risk rules
"""
func add_troops_to_player() -> void:
	var TroopCount = $Ui/MenuBar/Container/TroopCount
	
	var increment = max(3, current_player.get_owned().size()/3)
	increment += get_bonuses()
	current_player.increment_troops(increment)
	TroopCount.text = "Troop Count: {0}".format([current_player.get_troops()])
	

"""
 - iterates player queue via modular arithmetic
 - resets turn to adding troops, if not in initial state
"""
func next_turn() -> void:
	end_of_turn_draw_card(current_player)
	print(current_player.get_owned())
	turn_number += 1
	current_player = players[turn_number % players.size()]
	if current_game_state != GameState.INITIAL_STATE:
		add_troops_to_player()
		change_game_state(GameState.ADDING_TROOPS)
	$Ui.update_turn_ticker(current_player.get_id())
