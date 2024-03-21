extends Node

var board_state: Board.GameState

# Called when the node enters the scene tree for the first time.
func _ready():
	board_state = Board.GameState.adding_troops
	$Ui.update_game_state("adding_troops")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ui_change_state():
	match board_state:
		Board.GameState.adding_troops:
			board_state = Board.GameState.select_attacker
			$Ui.update_game_state("select_attacker")
		Board.GameState.select_attacker:
			board_state = Board.GameState.moving_troops
			$Ui.update_game_state("moving_troops")
		Board.GameState.moving_troops:
			board_state = Board.GameState.adding_troops
			$Ui.update_game_state("adding_troops")
