extends Node2D

var _latest_clicked
var _connecting := false
var _connecting_from

func _ready():
	$Board._editing = true
	$Board.clear_connections()
	$Board.draw_connections()
	$Board.register_territory_handlers(handle_node_clicked)
	var board = $Board
	
	$MenuBar/Container/Button.pressed.connect(func(): 
		if board.serialize_board():
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	$MenuBar/Container/ResetButton.pressed.connect(func(): 
		var dir = DirAccess.open("user://")
		dir.remove("board.json")
		get_tree().reload_current_scene()
	)

func handle_node_clicked(territory):
	if not _connecting:
		_connecting = true
		var mouse_pos = get_viewport().get_mouse_position()
		$Line2D.clear_points()
		$Line2D.add_point(territory.position)
		$Line2D.add_point(mouse_pos)
		$Line2D.visible = true
		_connecting_from = territory
	else:
		$Line2D.visible = false
		_connecting = false
		$Board.add_edge(_connecting_from, territory)
		_connecting_from = null
		$Board.clear_connections()
		$Board.draw_connections()
		
func _process(delta):
	if _connecting:
		var mouse_pos = get_viewport().get_mouse_position()
		$Line2D.remove_point(1)
		$Line2D.add_point(mouse_pos)
