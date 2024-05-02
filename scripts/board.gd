extends Node
class_name Board

"""Im momentarily commenting out everything playerQueue cuz it doesnt run with it"""

const Territory = preload("res://scenes/territory.tscn")
var graph: Graph
var _editing := false
var continents
const line_tscn = preload("res://scenes/line.tscn")

signal territory_clicked(which)
# Called when the node enters the scene tree for the first time.
func _ready():
	var data = read_json()

	init_territories(data["continents"])
	
	var staging_continents: Array[String] = []
	for continent in $Continents.get_children():
		staging_continents.append(continent.name)
	continents = staging_continents
	
	# collect territories into Dictionary
	# key: continent
	# value: list of territories belonging to continent
	var territories: Array[Territory] = []
	for continent in $Continents.get_children():
		territories.append_array(continent.get_children())
	graph = Graph.new(territories)
	
	var edges = data["edges"]
	graph.add_edges(edges)
	print("READY (board.gd)")

func read_json():
	#if false:
	if FileAccess.file_exists("user://board.json"):
		print("reading user board")
		var file = FileAccess.open("user://board.json", FileAccess.READ)
		var content = file.get_as_text()
		return JSON.parse_string(content)
	else:
		print("reading default board")
		var file = FileAccess.open("res://assets/default_board.json", FileAccess.READ)
		var content = file.get_as_text()
		return JSON.parse_string(content)

func write_json(json):
	var content = JSON.stringify(json)
	var file = FileAccess.open("user://board.json", FileAccess.WRITE)
	file.store_string(content)

func serialize_board() -> bool:
	if not graph.all_territories_connected():
		print("A territory is not connected. Cannot save.")
		return false
	# todo check if board is connected
	var json_object = {}
	json_object["edges"] = graph.get_edges()
	json_object["continents"] = {}
	
	for continent in $Continents.get_children():
		json_object["continents"][continent.name] = {}
		json_object["continents"][continent.name]["territories"] = {}
		for territory in continent.get_children():
			json_object["continents"][continent.name]["territories"][territory.name] = {}
			json_object["continents"][continent.name]["territories"][territory.name]["id"] = territory._graph_id
			json_object["continents"][continent.name]["territories"][territory.name]["x"] = territory.position.x
			json_object["continents"][continent.name]["territories"][territory.name]["y"] = territory.position.y

	write_json(json_object)
	return true
"""
Loops over every territory doing 3 main things:
	- adds key value pair of string continent name to list of territory nodes
		- No type hinting for dicts in GDScript, if it were possible: Dictionary[String, Array[Territory]]
	- sets value of each territory node's continent to respective string
	- connects every territories left click signal to _on_territory_clicked()
"""
func init_territories(continents):
	for continent in continents:
		var cont_node = Node.new()
		cont_node.name = continent
		$Continents.add_child(cont_node)
		for territory in continents[continent]["territories"]:
			var territory_node = preload("res://scenes/territory.tscn").instantiate()
			territory_node._graph_id = int(continents[continent]["territories"][territory]["id"])
			territory_node.position = Vector2(int(continents[continent]["territories"][territory]["x"]), int(continents[continent]["territories"][territory]["y"]))
			
			territory_node.name = territory
			cont_node.add_child(territory_node)
			territory_node.update_info()
			territory_node.territory_clicked.connect(_on_territory_clicked)

	#var continents : Dictionary
	#var continent_name: String
	#for continent: Node in $Continents.get_children():
		#if continent not in continents.keys():
			#continent_name = continent.get_name()
			#continents[continent_name] = []
		#for territory: Area2D in continent.get_children():
			#continents[continent_name].append(territory)
			#territory.set_continent(continent_name)
			#territory.territory_clicked.connect(_on_territory_clicked)

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
func draw_line(from: Vector2, to: Vector2):
	var line = Line2D.new()
	$Connections.add_child(line)
	line.add_point(from)
	line.add_point(to)
	line.get_parent().move_child(line, 0)
	return line

func draw_del(line, edge):
	var from = line.get_point_position(0)
	var to = line.get_point_position(1)
	var button = Button.new()
	button.text = "x"
	button.position = ((from+to)/2.0) - Vector2(8.0, 15.0)
	line.add_child(button)
	button.pressed.connect(func(): 
		delete_edge(edge)
		clear_connections()
		draw_connections()
	)

func delete_edge(edge):
	graph._edges.remove_at(graph._edges.find(edge))
	#clear_connections()
	#draw_connections(graph)

func add_edge(from: Territory, to: Territory):
	# Check if edge is in graph edges
	if graph.get_edges().find([from.get_id(), to.get_id()]) != -1:
		return
		
	# Check if reversed edge is in graph edges
	if graph.get_edges().find([to.get_id(), from.get_id()]) != -1:
		return
	
	# Check if edge is circular	
	if from.get_id() == to.get_id():
		return
	graph.add_edge(from.get_id(), to.get_id())
	#clear_connections()
	#draw_connections(graph)

"""
loops through edge list of graph, drawing Line2D's under Connections Node from graph node to graph node
"""
func draw_connections() -> void:
	for edge in graph.get_edges():
		if edge == [0,29] or edge == [29,0]: #wrap around edge as to not kill our eyes
			draw_del(draw_line(graph.get_node(0).position,Vector2(0,125)), edge)
			draw_del(draw_line(graph.get_node(29).position, Vector2(2000,137)), edge)
			continue
		draw_del(draw_line(graph.get_node(edge[0]).position, graph.get_node(edge[1]).position), edge)

func clear_connections():
	for child in $Connections.get_children():
		child.queue_free()

func register_territory_handlers(caller: Callable):
	for node in graph.get_nodes():
		node.pressed.connect(caller.bind(node))

func _on_territory_clicked(which: Territory):
	territory_clicked.emit(which)

"""
Rick!
"""
func player_controls_continent(player, continent_name: String):
	var territories = $Continents.get_node(continent_name).get_children()
	for territory in territories:
		if territory.get_ownership() == null or territory.get_ownership() != player:
			return false
	return true

func player_controls_third_continent(player, exceptions: Array) -> bool:
	for continent_name in continents.keys():
		if continent_name not in exceptions and player_controls_continent(player, continent_name):
			return true
	return false
