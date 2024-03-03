class_name Graph
	
var _graph
var _vertices
var _edges

func _init(vertices: Array):
	_edges = []
	_vertices = vertices
	_graph = {}
	for i in len(vertices):
		_graph[i] = []

func get_vertex(index):
	return _vertices[index]

func get_graph():
	return _graph

func get_edges():
	return _edges

func add_edge(v, w):
	_edges.append([v,w])
	_graph[v].append(w)
	_graph[w].append(v)

func connected(v,w):
	return(v in _graph[w])

func dfs(start_node):
	var edges = [start_node]
	var checked = 0
	while checked < edges.size():
		for edge in _graph[edges[checked]]:
			if !(edge in edges):
				edges.append(edge)
		checked += 1
	return edges
