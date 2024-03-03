extends Node

const Territory = preload("res://territory.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var t1 = instantiate_territory(Vector2(250,250))
	var t2 = instantiate_territory(Vector2(500,250))
	var t3 = instantiate_territory(Vector2(120,100))
	var t4 = instantiate_territory(Vector2(250,400))
	var t5 = instantiate_territory(Vector2(700,300))
	var graph = Graph.new([t1,t2,t3,t4,t5])
	
	
	print(graph.get_graph())
	
	graph.add_edge(0,1)
	graph.add_edge(0,2)
	graph.add_edge(0,3)
	graph.add_edge(1,3)
	graph.add_edge(1,4)
	
	print(graph.get_edges())
	print(graph.get_graph())
	print(graph.get_graph()[0])
	
	draw_connections(graph)
	
	print_tree_pretty()

func _process(delta):
	pass
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
	add_child(line)
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

