extends Node
class_name Board

"""Im momentarily commenting out everything playerQueue cuz it doesnt run with it"""

const Territory = preload("res://scenes/territory.tscn")
var graph: Graph
var continents

signal territory_clicked(which)
# Called when the node enters the scene tree for the first time.
func _ready():
	print("READY (board.gd)")
	continents = connect_and_get_continent_dict()
	var selected: Area2D
	
	# collect territories into Dictionary
	# key: continent
	# value: list of territories belonging to continent
	var territories: Array[Territory] = []
	for continent in continents.values():
		territories.append_array(continent)
	graph = Graph.new(territories)
	
	"deleted duplicated [1,3 edge]. changed edge [2,4] to [6,4]"
	# Disgustingly long list of edges, maybe port to text file?
	var edges = [[0,1],[0,3],[1,3],[1,2],[1,4],[6,4],[2,5],[3,6],[3,4],[4,5],[4,7],[5,7],[6,7],[6,8],[7,8], # North America Edges
	[9,10],[9,11],[10,11],[10,12],[11,12], # South America Edges
	[13,14],[13,15],[13,16],[14,15],[15,16],[15,17],[15,18],[16,17],[17,18], # Africa Edges
	[19,21],[19,20],[20,21],[20,23],[20,25],[21,23],[21,22],[22,23],[22,24],[23,24],[23,25],[24,25], # Europe Edges
	[26,27],[26,32],[26,34],[27,28],[27,30],[27,31],[27,32],[28,29],[28,30],[29,30],[29,33],[29,31],[30,31],[31,33],[31,32],[32,35],[32,36],[34,32],[34,37],[34,35],[35,36],[37,35],  # Asia Edges
	[38,39],[38,40],[39,41],[41,40], # Australia Edges
	[2,19],[8,9],[0,29],[10,13],[25,13],[14,24],[14,37],[36,38],[22,26],[22,34],[22,37],[24,37],[15,37] # Intercontinental Edges
	]
	graph.add_edges(edges)
	# draw_connections(graph)
	# populate(edges)
	# game_loop()


"""
Loops over every territory doing 3 main things:
	- adds key value pair of string continent name to list of territory nodes
		- No type hinting for dicts in GDScript, if it were possible: Dictionary[String, Array[Territory]]
	- sets value of each territory node's continent to respective string
	- connects every territories left click signal to _on_territory_clicked()
"""
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

"""
creates territory scene, adds to node tree, and sets position to Vector2 argument
"""
func instantiate_territory(pos: Vector2) -> Territory:
	var instance = Territory.instantiate()
	add_child(instance)
	# instance.set_id(id)
	instance.position = pos
	return instance
"""
creates Line2D node, adds to scene, sets points to 2 Vector2's given
"""
func draw_line(from: Vector2, to: Vector2) -> Line2D:
	var line = Line2D.new()
	$Connections.add_child(line)
	line.add_point(from)
	line.add_point(to)
	line.get_parent().move_child(line, 0)
	return line

"""
loops through edge list of graph, drawing Line2D's under Connections Node from graph node to graph node
"""
func draw_connections(graph: Graph) -> void:
	for edge in graph.get_edges():
		if edge == [0,29]: #wrap around edge as to not kill our eyes
			draw_line(graph.get_node(0).position,Vector2(0,125))
			draw_line(graph.get_node(29).position, Vector2(2000,137))
			continue
		draw_line(graph.get_node(edge[0]).position, graph.get_node(edge[1]).position)

func _on_territory_clicked(which: Territory):
	territory_clicked.emit(which)
	

"""
Rick!
"""
func player_controls_continent(player_id: int, continent_name: String):
	var territories = continents[continent_name]
	for territory in territories:
		if territory.get_ownership() != player_id:
			return false
	return true
