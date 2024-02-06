class Board:
    func _init(board_nodes: Array[Node]):
        var nodes = board_nodes

class Territory:
    func _init(territory_connections: Array[Node], territory_continent: Continent):
        var connections = territory_connections
        var continent = territory_connections

enum Continent {AFRICA, ASIA, AUSTRALIA, EUROPE, NORTH_AMERICA, SOUTH_AMERICA}
