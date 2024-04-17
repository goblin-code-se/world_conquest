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
	turn_number = 0
	players = []
	for i in range(5):
		players.append(Player.new(i+1, 25))
	current_player = players[0]
	current_game_state = GameState.INITIAL_STATE
	$Ui.update_game_state("INITIAL STATE")
	board_graph = $Board_Main.graph
	edges = board_graph.get_edges()
	continent_bonuses = {"North America": 5, 
						"South America": 2, 
						"Africa": 3, 
						"Europe": 5, 
						"Asia": 7, 
						"Australia": 2}
	
	# populate(edges)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

"""Rick!"""
# var current_game_state = GameState.SELECT_ATTACKER # This shouldn't be left like that
# Recommendation: In _ready() specify the game state at every state. There should be a general "do nothing" state and be changed for ATTACK when, welp, ATTACKing
# Also, these ATTACKing/defender could be added to the ATTACK() function, and just call it when, WELP, ATTACKing, so it re-starts
#Also, probably a more descriptive name would be populate_adjacent_list or something like that
"""
this is already done in Graph class method get_adjacent_nodes()

func populate(edges):
	for edge in edges:
		if edge[0] not in adjacent_territories:
			adjacent_territories[edge[0]] = []
		if edge[1] not in adjacent_territories:
			adjacent_territories[edge[1]] = []
		adjacent_territories[edge[0]].append(edge[1])
		adjacent_territories[edge[1]].append(edge[0])
"""

func attack(attacking_territory: Territory, defender_territory: Territory):
	var attacker_losses = 0
	var defender_losses = 0
	
	var attack_dice = []
	for i in range(3):
		attack_dice.append(randi() % 6 +1)
	attack_dice.sort()
	attack_dice.reverse()
	
	var defense_dice = []
	for i in range(2):
		defense_dice.append(randi() % 6 +1)
	defense_dice.sort()
	defense_dice.reverse()
	
	for i in range(min(attack_dice.size(), defense_dice.size())):
		if attack_dice[i] > defense_dice[i]:
			defender_losses +=1
		else:
			attacker_losses +=1
	

func _on_attack_button_pressed() -> void:
	change_game_state(GameState.SELECT_ATTACKER)

func _on_move_button_pressed() -> void:
	change_game_state(GameState.MOVING_FROM)

func _on_board_main_territory_clicked(which: Territory):
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
			# checking whether all players have depleted yet
			handle_initial_adding(which)
				

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
	from.increment_troops(-amount)
	to.increment_troops(amount)

func handle_initial_adding(which):
	handle_adding(which)
	if players[players.size()-1].get_troops() == 0:
		change_game_state(GameState.ADDING_TROOPS)
		next_turn()
	else:
		next_turn()

func handle_adding(which):
	if which.get_ownership() == current_player.get_id() or which.get_ownership() == 0:
		if current_player.get_troops() > 0:
			print("adding troops")
			which.increment_troops(1) # can add multiple at a time eventually to help with turns of huge amounts of troops
			current_player.increment_troops(-1)
			if which.get_ownership() == 0:
				which.set_ownership(current_player.get_id())
	if current_player.get_troops() == 0 and current_game_state != GameState.INITIAL_STATE:
		change_game_state(GameState.SELECT_ATTACKER)

	$Ui.update_troop_count(current_player.get_troops())
		
func handle_selecting_attacker(which):
	if which.get_ownership() == current_player.get_id(): # This 0 has to be changed to player id
		attacking_territory = which
		print("Attacker territory: ", which.get_id())
		change_game_state(GameState.SELECT_ATTACKED)
	else:
		print("not your territory bro")

func change_game_state(game_state: GameState):
	current_game_state = game_state
	$Ui.update_game_state(GameState.keys()[game_state])

func handle_select_attacked(which):
	var adjacent: bool = which.get_id() in board_graph.get_adjacent_nodes(attacking_territory.get_id())
	if adjacent and which.get_ownership() != current_player.get_id(): #and which.get_ownership() != attacking_territory.get_ownership():
		defender_territory = which
		change_game_state(GameState.SELECT_ATTACKED)
		print("defender: ", which.get_id())
		change_game_state(GameState.SELECT_ATTACKER)
	else:
		print("can't attackkkkk")

func handle_moving_from(which):
	if which.get_ownership() == current_player.get_id() and which.get_troop_number() > 1:
		moving_from = which
		change_game_state(GameState.MOVING_TO)
	else:
		print("not your territory")

func handle_moving_to(which):
	if which.get_ownership() == current_player.get_id():
		moving_to = which
		if valid_move(moving_from, moving_to):
			print("valid movement")
			move(moving_from, moving_to, 1)
			change_game_state(GameState.MOVING_FROM)
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
	
func add_troops_to_player():
	var TroopCount = $Ui/MenuBar/Container/TroopCount
	
	var increment = max(3, current_player.get_owned().size())
	increment += get_bonuses()
	current_player.increment_troops(increment)
	TroopCount.text = "Troop Count: {0}".format([current_player.get_troops()])

func next_turn():
	turn_number += 1
	current_player = players[turn_number % players.size()]
	if current_game_state != GameState.INITIAL_STATE:
		add_troops_to_player()
		change_game_state(GameState.ADDING_TROOPS)
	$Ui.update_turn_ticker(current_player.get_id())
	
