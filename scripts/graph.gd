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

func get_nodes() -> Array:
	return _nodes

func get_node(index: int) -> Territory:
	return _nodes[index]

func get_graph() -> Dictionary:
	return _graph

func get_edges() -> Array:
	return _edges

func add_edge(v: int, w: int) -> void:
	_edges.append([v,w])
	_graph[v].append(w)
	_graph[w].append(v)

func add_edges(edges: Array) -> void:
	for edge in edges:
		add_edge(edge[0],edge[1])

func connected(v: int,w: int) -> bool:
	return(v in _graph[w])


"""
performs depth first search
 - returns list of node IDs directly connected to start_node
"""
func dfs(start_node: int) -> Array:
	var nodes = [start_node]
	var current_player = get_node(start_node).get_ownership()
	var checked = 0
	while checked < nodes.size():
		for node in _graph[nodes[checked]]:
			if !(node in nodes) and get_node(node).get_ownership() == current_player:
				nodes.append(node)
		checked += 1
	return nodes

func get_adjacent_nodes(node_id: int) -> Array:
	return _graph[node_id]

func all_territories_owned() -> bool:
	for node in _nodes:
		if node.get_ownership() == 0:
			return false
	return true

"
func get_adjacent_territories(id: int) -> Array:
	var adjacent_nodes: Array = []
	for i in _graph[id]:
		adjacent_nodes.append(_nodes[i])
	return adjacent_nodes
"
