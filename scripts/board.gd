const Player = preload("res://scripts/player.gd")

class Board:
	func _init(board_nodes: Array[Node]):
		var nodes = board_nodes

class Territory:
<<<<<<< HEAD
	func _init(territory_connections: Array[Node], territory_continent: Continent):
		var connections = territory_connections
		var continent = territory_connections
=======
    func _init(territory_connections: Array[Node], territory_continent: Continent):
        var connections = territory_connections
        var continent = territory_connections
        var owner: Player
        var soldiers: int = 0
>>>>>>> 16b3dc03e5357703a56ce67f336dfe0e214333cd

enum Continent {AFRICA, ASIA, AUSTRALIA, EUROPE, NORTH_AMERICA, SOUTH_AMERICA}
