extends Node2D

enum Player {P0, P1, P2, P3, P4, P5}

var continent 
var who_owns = Player.P1 # allows for changing through inspector
var troop_number
var hover
var graph_id

# Called when the node enters the scene tree for the first time.

func _ready():
	self.continent = "test continent"
	self.troop_number = 0
	update_info()
	update_sprite()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# called for every frame mouse is hovering over territory
	if hover:
		# without offest Vec, text covered by mouse
		$HoverInfo.global_position = get_global_mouse_position() + Vector2(10,10)

# Call everytime variables to do with territory information changes:
func update_info():
	$HoverInfo.text = "continent: {0}
	who_owns: {1}
	troop_number: {2}
	graph_id: {3}".format([continent, who_owns, str(troop_number), str(graph_id)])

func set_ownership(player):
	self.who_owns = player
	update_sprite()

func update_sprite():
	# no default case on match as who_owns should never not be in Player enum
	match who_owns:
		Player.P0:
			$Sprite2d.texture = preload("res://assets/faction 0.png")
		Player.P1:
			$Sprite2D.texture = preload("res://assets/faction 1.png")
		Player.P2:
			$Sprite2D.texture = preload("res://assets/faction 2.png")
		Player.P3:
			$Sprite2D.texture = preload("res://assets/faction 3.png")
		Player.P4:
			$Sprite2D.texture = preload("res://assets/faction 4.png")
		Player.P5:
			$Sprite2D.texture = preload("res://assets/faction 5.png")

func set_id(id: int):
	graph_id = id
	update_info()

func _on_mouse_entered():
	$HoverInfo.show()
	hover = true


func _on_mouse_exited():
	$HoverInfo.hide()
	hover = false
	
