class_name Graph
	
var _graph
var _nodes: Array[Territory]
var _edges

func _init(nodes: Array[Territory]):
	
	var to_be_inserted: Array[Territory] = []
	_nodes = nodes
	_edges = []
	
	_graph = {}
	for node in nodes:
		_graph[node._graph_id] = []
		#nodes[i].set_id(i)

func get_nodes() -> Array[Territory]:
	return _nodes

func get_node(index: int) -> Territory:
	for node in _nodes:
		if node._graph_id == index:
			return node
	return null
	#var node = _nodes.find(func(node): node._graph_id == index)
	#assert (node != -1, "Not found")
	#assert (_nodes[node]._graph_id == index)
	#return _nodes[node]

func get_graph() -> Dictionary:
	return _graph

func get_edges():
	return _edges

func add_edge(v: int, w: int) -> void:
	_edges.append([v,w])
	_graph[v].append(w)
	_graph[w].append(v)

func add_edges(edges) -> void:
	for edge in edges:
		add_edge(edge[0],edge[1])

func connected(v: int,w: int) -> bool:
	return(v in _graph[w])


"""
performs depth first search
 - returns list of node IDs directly connected to start_node
"""
func dfs(start_node: Territory) -> Array[Territory]:
	var nodes: Array[Territory] = [start_node]
	var current_player = start_node.get_ownership()
	var checked = 0
	while checked < nodes.size():
		for node_id in _graph[nodes[checked].get_id()]:
			var node_obj = get_node(node_id)
			var unvisited = !(node_obj in nodes)
			var player_owned = node_obj.get_ownership().get_id() == current_player.get_id()
			if unvisited and player_owned:
				nodes.append(node_obj)
		checked += 1
	return nodes

func get_adjacent_nodes(node_id: int):
	return _graph[node_id]

func all_territories_owned() -> bool:
	for node in _nodes:
		if node.get_ownership() == null:
			return false
	return true

"
func get_adjacent_territories(id: int) -> Array:
	var adjacent_nodes: Array = []
	for i in _graph[id]:
		adjacent_nodes.append(_nodes[i])
	return adjacent_nodes
"

func all_territories_connected() -> bool:
	var nodes: Array[Territory] = [_nodes.pick_random()]
	var checked = 0
	while checked < nodes.size():
		for node_id in _graph[nodes[checked].get_id()]:
			var node_obj = get_node(node_id)
			var unvisited = !(node_obj in nodes)
			if unvisited:
				nodes.append(node_obj)
		checked += 1
	
	for node in _nodes:
		if node not in nodes:
			return false
	return true

func all_connected_territories(territory: Territory) -> Array[Territory]:
	print("insanity check .-.")
	var nodes: Array[Territory] = [territory]
	var checked = 0
	while checked < nodes.size():
		for node_id in _graph[nodes[checked].get_id()]:
			var node_obj = get_node(node_id)
			var unvisited = node_obj not in nodes
			if unvisited and node_obj.get_ownership() == territory.get_ownership():
				nodes.append(node_obj)
		checked += 1
	return nodes.slice(1)
