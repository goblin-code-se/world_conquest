extends Node
class_name Board

const IterTools = preload("res://scripts/itertools.gd")
const Territory = preload("res://scenes/territory.tscn")
var currentPlayer: int
var playerQueue: Queue
var players: Array[Player]
var graph: Graph
var iterTools = IterTools.new()
var current_game_state

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Continents/North America/Alaska".set_ownership(1)
	playerQueue = Queue.new()
	var player: Player
	for i in range(5):
		player = Player.new(i, 0)
		players.append(player)
		playerQueue.enqueue(player)
		
	
	var continents = connect_and_get_continent_dict()
	var selected: Area2D
	var currentPlayer: int = 0
	
	# collect territories into Dictionary
	# key: continent
	# value: list of territories belonging to continent
	var territories: Array = []
	for continent: Array in continents.values():
		territories.append_array(continent)
	graph = Graph.new(territories)
	
	# Disgustingly long list of edges, maybe port to text file?
	var edges = [[0,1],[0,3],[1,3],[1,2],[1,3],[1,4],[2,4],[2,5],[3,6],[3,4],[4,5],[4,7],[5,7],[6,7],[6,8],[7,8], # North America Edges
	[9,10],[9,11],[10,11],[10,12],[11,12], # South America Edges
	[13,14],[13,15],[13,16],[14,15],[15,16],[15,17],[15,18],[16,17],[17,18], # Africa Edges
	[19,21],[19,20],[20,21],[20,23],[20,25],[21,23],[21,22],[22,23],[22,24],[23,24],[23,25],[24,25], # Europe Edges
	[26,27],[26,32],[26,34],[27,28],[27,30],[27,31],[27,32],[28,29],[28,30],[29,30],[29,33],[29,31],[30,31],[31,33],[31,32],[32,35],[32,36],[34,32],[34,37],[34,35],[35,36],[37,35],  # Asia Edges
	[38,39],[38,40],[39,41],[41,40], # Australia Edges
	[2,19],[8,9],[0,29],[10,13],[25,13],[14,24],[14,37],[36,38],[22,26],[22,34],[22,37],[24,37],[15,37] # Intercontinental Edges
	]
	graph.add_edges(edges)
	draw_connections(graph)
	populate(edges)
	currentPlayer = 0
	# game_loop()
	
	
	
func _process(delta):
	pass

"
Loops over every territory doing 3 main things:
	- adds key value pair of string continent name to list of territory nodes
		- No type hinting for dicts in GDScript, if it were possible: Dictionary[String, Array[Territory]]
	- sets value of each territory node's continent to respective string
	- connects every territories left click signal to _on_territory_clicked()
"
func connect_and_get_continent_dict() -> Dictionary:
	var continents : Dictionary
	var continent_name: String
	for continent: Node in $Continents.get_children():
		if continent not in continents.keys():
			continent_name = continent.get_name()
			continents[continent_name] = []
		for territory: Area2D in continent.get_children():
			continents[continent_name].append(territory)
			territory.set_continent(continent_name)
			territory.territory_clicked.connect(_on_territory_clicked)
	return continents

"
creates territory scene, adds to node tree, and sets position to Vector2 argument
"
func instantiate_territory(pos: Vector2) -> Territory:
	var instance = Territory.instantiate()
	add_child(instance)
	# instance.set_id(id)
	instance.position = pos
	return instance
"
creates Line2D node, adds to scene, sets points to 2 Vector2's given
"
func draw_line(from: Vector2, to: Vector2) -> Line2D:
	var line = Line2D.new()
	$Connections.add_child(line)
	line.add_point(from)
	line.add_point(to)
	line.get_parent().move_child(line, 0)
	return line

"
loops through edge list of graph, drawing Line2D's under Connections Node from graph node to graph node
"
func draw_connections(graph: Graph) -> void:
	for edge in graph.get_edges():
		if edge == [0,29]: #wrap around edge as to not kill our eyes
			draw_line(graph.get_node(0).position,Vector2(0,125))
			draw_line(graph.get_node(29).position, Vector2(2000,137))
			continue
		draw_line(graph.get_node(edge[0]).position, graph.get_node(edge[1]).position)


"""Rick!"""
# enum for the game states.
# This should later be expanded to cover all possible game states, like reinforcing etc
enum GameState {
	select_attacker,
	select_attacked,
	adding_troops,
	attack,
	moving_troops
}

# var current_game_state = GameState.select_attacker # This shouldn't be left like that
# Recommendation: In _ready() specify the game state at every state. There should be a general "do nothing" state and be changed for attack when, welp, attacking
# Also, these attacking/defender could be added to the attack() function, and just call it when, WELP, attacking, so it re-starts
var attacking_territory: Territory = null
var defender_territory: Territory = null

func _on_territory_clicked(which: Territory):
	match current_game_state:
		GameState.adding_troops:
			print("adding troops")
			if which.get_ownership() == currentPlayer:
				which.increment_troops(1) # can add multiple at a time eventually to help with turns of huge amounts of troops
		GameState.select_attacker:
			if which.get_ownership() == currentPlayer: # This 0 has to be changed to player id
				attacking_territory = which
				print("Attacker territory: ", which.get_id())
				current_game_state = GameState.select_attacked
			else:
				print("not your territory bro")
		GameState.select_attacked:
			if which.get_id() in adjacent_territories[attacking_territory.get_id()]: #and which.get_ownership() != attacking_territory.get_ownership():
				defender_territory = which
				current_game_state = GameState.select_attacked
				print("defender: ", which.get_id())
			else:
				print("can't attackkkkk")
	
var adjacent_territories = {} #Yeah this var should also be added to attack() probs.
#Also, probably a more descriptive name would be populate_adjacent_list or something like that
func populate(edges):
	for edge in edges:
		if edge[0] not in adjacent_territories:
			adjacent_territories[edge[0]] = []
		if edge[1] not in adjacent_territories:
			adjacent_territories[edge[1]] = []
		adjacent_territories[edge[0]].append(edge[1])
		adjacent_territories[edge[1]].append(edge[0])


func attack(attacking_territory, defender_territory):
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
	
"""John!"""
func is_game_over() -> int:
	var winner = graph.get_nodes()[0].get_ownership()
	for node in graph.get_nodes():
		if node.get_ownership() != winner:
			return -1
	return winner

"
func game_loop():
	print(\"entered main game loop\")
	while is_game_over() < 0:
		current_game_state = GameState.adding_troops
		while current_game_state == GameState.adding_troops:
			current_game_state = GameState.adding_troops
		current_game_state = GameState.attack
		current_game_state = GameState.moving_troops
"		
