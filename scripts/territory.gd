extends Node2D

var continent: String
var who_owns: int
var troop_number: int
var hover: bool
var selected: bool = false
var graph_id: int

# Called when the node enters the scene tree for the first time.

func _ready():
	self.continent = "test continent"
	self.troop_number = 0
	$TerritoryName.text = self.get_name()
	update_info()
	update_sprite()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# called for every frame mouse is hovering over territory
	if hover:
		# without offest Vec, text covered by mouse
		$HoverInfo.global_position = get_global_mouse_position() + Vector2(10,10)

# Call everytime variables to do with territory information changes:
func update_info() -> void:
	$TroopCount.text = str(troop_number)
	$HoverInfo.text = "continent: {0}
	who_owns: {1}
	graph_id: {2}".format([continent, who_owns, str(graph_id)])

func set_ownership(player: int) -> void:
	self.who_owns = player
	update_sprite()
	
func set_continent(continent: String) -> void:
	self.continent = continent
	update_info()

func increment_troops(count: int) -> void:
	self.troop_number += count
	update_info()

func update_sprite() -> void:
	# no default case on match as who_owns should never not be in Player enum
	match who_owns:
		1:
			$Sprite2D.texture = preload("res://assets/factions/blue faction.png")
		2:
			$Sprite2D.texture = preload("res://assets/factions/dark faction.png")
		3:
			$Sprite2D.texture = preload("res://assets/factions/orange faction.png")
		4:
			$Sprite2D.texture = preload("res://assets/factions/purple faction.png")
		5:
			$Sprite2D.texture = preload("res://assets/factions/yellow faction.png")
		_:
			pass

func set_id(id: int) -> void:
	graph_id = id
	update_info()

func _on_mouse_entered():
	$HoverInfo.show()
	$SelectBox.show()
	hover = true


func _on_mouse_exited():
	if !selected:
		$SelectBox.hide()
	$HoverInfo.hide()
	hover = false
	
