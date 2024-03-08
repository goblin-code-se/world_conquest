extends Node

const Territory = preload("res://scenes/territory.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var graph: Graph
	var continents = get_continent_dict()
	# collect territories into Dictionary
	# key: continent
	# value: list of territories belonging to continent
	var territories: Array = []
	for continent: Array in continents.values():
		territories.append_array(continent)
	
	graph = Graph.new(territories)
	
	var edges = [[0,1],[0,3],[1,3],[1,2],[1,3],[1,4],[2,4],[2,5],[3,6],[3,4],[4,5],[4,7],[5,7],[6,7],[6,8],[7,8] # North America Edges
	]
	graph.add_edges(edges)
	draw_connections(graph)

func _process(delta):
	pass

func get_continent_dict() -> Dictionary:
	var continents : Dictionary
	var continent_name: String
	for continent: Node in $Continents.get_children():
		if continent not in continents.keys():
			continent_name = continent.get_name()
			continents[continent_name] = []
		for territory: Area2D in continent.get_children():
			continents[continent_name].append(territory)
			territory.set_continent(continent_name)
	return continents

"
creates territory scene, adds to node tree, and sets position to arg
"
func instantiate_territory(pos: Vector2) -> Area2D:
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
v1 more elegant and does exactly what is required
"
func draw_connections(graph: Graph) -> void:
	for edge in graph.get_edges():
		draw_line(graph.get_node(edge[0]).position, graph.get_node(edge[1]).position)

