extends Node

const Territory = preload("res://territory.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var t1 = instantiate_territory(Vector2(250,250), 0)
	var t2 = instantiate_territory(Vector2(500,250), 1)
	var t3 = instantiate_territory(Vector2(120,100), 2)
	var t4 = instantiate_territory(Vector2(250,400), 3)
	var t5 = instantiate_territory(Vector2(700,300), 4)
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
'''
creates territory scene, adds to node tree, and sets position to args
'''
func instantiate_territory(pos: Vector2, id: int):
	var instance = Territory.instantiate()
	add_child(instance)
	instance.set_id(id)
	instance.position = pos
	return instance
'''
creates Line2D node, adds to scene, sets points to 2 Vector2's given
'''
func draw_line(from: Vector2, to: Vector2):
	var line = Line2D.new()
	add_child(line)
	line.add_point(from)
	line.add_point(to)
	line.get_parent().move_child(line, 0)
	return line

'''
v1
BFS search on given graph, drawing lines between each node with a connection
- this only draws one route however, need to think of different implementation
- keep incase pathfinding needed anyway
'''
'''
func draw_connections(graph):
	var current
	var visited = [0]
	var queue = [0]
	
	while !queue.is_empty():
		
		current = queue.pop_front()
		# print("Visiting: ")
		print(current)
		for adj in graph.graph[current]:
			# print("Searching adj: ")
			print(adj)
			if !(adj in visited):
				# print("{0} not visited yet, drawing line from {0} to {1}".format([str(adj),str(current)]))
				var line = draw_line(graph.get_vertex(current).position, graph.get_vertex(adj).position)
				line.get_parent().move_child(line, 0) # moves behind graph
				visited.append(adj)
				queue.push_back(adj)
'''

'''
v1 more elegant and does exactly what is required
'''
func draw_connections(graph):
	for edge in graph.get_edges():
		draw_line(graph.get_vertex(edge[0]).position, graph.get_vertex(edge[1]).position)
	print("meow")

