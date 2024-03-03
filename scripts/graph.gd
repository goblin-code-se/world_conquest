class_name Graph
	
var _graph: Dictionary
var _nodes: Array
var _edges: Array

func _init(nodes: Array):
	
	_edges = []
	_nodes = nodes
	_graph = {}
	for i in len(nodes):
		_graph[i] = []
		nodes[i].set_id(i)

func get_node(index: int) -> Area2D:
	return _nodes[index]

func get_graph() -> Dictionary:
	return _graph

func get_edges() -> Array:
	return _edges

func add_edge(v: int, w: int) -> void:
	_edges.append([v,w])
	_graph[v].append(w)
	_graph[w].append(v)

func connected(v: int,w: int) -> bool:
	return(v in _graph[w])
