extends Node2D
class_name Territory

var _owner
var _troop_number: int
var _hover: bool
var _selected: bool = false
var _graph_id: int

signal pressed
signal territory_clicked(which)
# Called when the node enters the scene tree for the first time.

func _ready():
	_troop_number = 0
	_owner = null
	$TerritoryName.text = self.get_name()
	update_info()
	update_sprite()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# called for every frame mouse is hovering over territory
	if _hover:
		# without offest Vec, text covered by mouse
		$HoverInfo.global_position = get_global_mouse_position() + Vector2(10,10)

# Call everytime variables to do with territory information changes:
func update_info() -> void:
	
	var player_name;
	if not _owner:
		player_name = "Nobody"
	else:
		player_name = "Player {0}".format([_owner.get_id()])
		
	$TroopCount.text = str(_troop_number)
	$HoverInfo.text = "continent: {0}
	who_owns: {1}
	graph_id: {2}".format([get_continent(), player_name, str(_graph_id)])
	$TerritoryName.text = self.get_name()

func get_ownership():
	return _owner

func set_ownership(player) -> void:
	_owner = player
	update_info()
	update_sprite()

func get_continent() -> String:
	return get_parent().name

func increment_troops(count: int) -> void:
	_troop_number += count
	if _owner:
		_owner.increment_troops(count)
	update_info()
	#print(self.get_name(), " receives 1 troop")
func decrement_troops(count: int) -> void:
	_troop_number -= count
	_owner.decrement_player_troops(count)
	update_info()

func get_troop_number() -> int:
	return _troop_number
	
func update_sprite() -> void:
	# no default case on match as who_owns should never not be in Player enum
	if not _owner:
		return
	
	match _owner.get_id():
		1:
			$Sprite2D.texture = preload("res://assets/factions/blue faction.png")
		2:
			$Sprite2D.texture = preload("res://assets/factions/black faction.png")
		3:
			$Sprite2D.texture = preload("res://assets/factions/orange faction.png")
		4:
			$Sprite2D.texture = preload("res://assets/factions/purple faction.png")
		5:
			$Sprite2D.texture = preload("res://assets/factions/yellow faction.png")

func get_id() -> int:
	return _graph_id

func set_id(id: int) -> void:
	_graph_id = id
	update_info()

func _on_mouse_entered():
	$HoverInfo.show()
	$SelectBox.show()
	_hover = true


func _on_mouse_exited():
	if !_selected:
		$SelectBox.hide()
	$HoverInfo.hide()
	_hover = false

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and \
	 event.button_index == MOUSE_BUTTON_LEFT and _hover:
			territory_clicked.emit(self)
			pressed.emit()
