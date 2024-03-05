class Player:
	func _init(player_name: String, player_colour: Colour, player_territory_sprite: String):
		var name = player_name
		var colour = player_colour
		var territory_sprite = player_territory_sprite

enum Colour {BLACK, BLUE, YELLOW, ORANGE, PURPLE}
