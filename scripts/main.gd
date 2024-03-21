extends Node

var current_game_state: GameState
var current_player: int
var attacking_territory
var defender_territory
var adjacent_territories
var board_graph: Graph
var edges: Array
var moving_from: Territory
var moving_to: Territory

enum GameState {
	SELECT_ATTACKER,
	SELECT_ATTACKED,
	ADDING_TROOPS,
	ATTACK,
	MOVING_FROM,
	MOVING_TO
}
# Called when the node enters the scene tree for the first time.
func _ready():
	current_player = 3
	current_game_state = GameState.ADDING_TROOPS
	$Ui.update_game_state("ADDING_TROOPS")
	board_graph = $Board_Main.graph
	edges = board_graph.get_edges()
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

func attack(attacking_territory, defender_territory):
	var ATTACKer_losses = 0
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
			ATTACKer_losses +=1
	


func _on_ui_change_state() -> void:
	match current_game_state:
		GameState.ADDING_TROOPS:
			current_game_state = GameState.SELECT_ATTACKER
			$Ui.update_game_state("SELECT_ATTACKER")
		GameState.SELECT_ATTACKER:
			current_game_state = GameState.MOVING_FROM
			$Ui.update_game_state("MOVING_TROOPS")
		GameState.MOVING_FROM:
			current_game_state = GameState.ADDING_TROOPS
			$Ui.update_game_state("ADDING_TROOPS")


func _on_board_main_territory_clicked(which: Territory):
	match current_game_state:
		GameState.ADDING_TROOPS:
			print("adding troops")
			if which.get_ownership() == current_player:
				which.increment_troops(1) # can add multiple at a time eventually to help with turns of huge amounts of troops
		GameState.SELECT_ATTACKER:
			if which.get_ownership() == current_player: # This 0 has to be changed to player id
				attacking_territory = which
				print("ATTACKer territory: ", which.get_id())
				current_game_state = GameState.SELECT_ATTACKED
			else:
				print("not your territory bro")
		GameState.SELECT_ATTACKED:
			var adjacent: bool = which.get_id() in board_graph.get_adjacent_nodes(attacking_territory.get_id())
			if adjacent and which.get_ownership() != current_player: #and which.get_ownership() != attacking_territory.get_ownership():
				defender_territory = which
				current_game_state = GameState.SELECT_ATTACKED
				print("defender: ", which.get_id())
				current_game_state = GameState.SELECT_ATTACKER
			else:
				print("can't attackkkkk")
		GameState.MOVING_FROM:
			if which.get_ownership() == current_player:
				moving_from = which
				current_game_state = GameState.MOVING_TO
			else:
				print("not your territory")
		GameState.MOVING_TO:
			if which.get_ownership() == current_player:
				moving_to = which
				if valid_move(moving_from, moving_to):
					print("valid movement")
					move(moving_from, moving_to, 1)
					current_game_state =  GameState.MOVING_FROM
				else:
					print("not reachable")
			else:
				print("not your territory")
				

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
returns whether or not a move to and from a territory is valid
 - returns true if both territories are connected and belong to same player
 - returns false otherwise
"""
func valid_move(from: Territory, to: Territory) -> bool:
	var connected_nodes = board_graph.dfs(from.get_id())
	if to.get_ownership() == current_player and to.get_id() in connected_nodes:
		return true
	return false

func move(from: Territory, to: Territory, amount: int):
	from.increment_troops(-amount)
	to.increment_troops(amount)
	
	
