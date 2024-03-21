extends CanvasLayer

const turn_time = 5*60+0.5 # Five minutes max for a turn, with small offset to properly start at 5:00 and not 4:59
@export var player_count = 5
@export var troop_count = 25
var current_player: Player
var players: TurnTracker
var gameState: String

@onready var tallies = $Tallies
@onready var turn_timer = $TurnTimer
@onready var turn_countdown = $MenuBar/Container/TurnCountdown
@onready var turn_ticker = $MenuBar/Container/TurnTicker

signal change_state()
# Queues players for turn rota, displays player troop counts, starts timer and sets current player as first in queue
func _ready():
	var arr: Array[Player]
	for i in range(1, player_count+1):
		arr.append(Player.new(i, troop_count))
		tallies.text += "P{num}: {troops}\n".format({"num":i, "troops":troop_count})
	players = TurnTracker.new(arr)
	turn_timer.start(turn_time) 
	current_player = players.peek()

# div by 60 to get minutes, mod by 60 to get seconds
# first, checks if exactly to a minute, if so, then adds extra zero so that "5:0" is corrected to "5:00"
# second, checks if seconds remaining to a minute is less than 10, if so, then adds extra zero in another place such that "4:9" is corrected to "4:09"
func _process(_delta): 
	if int(turn_timer.get_time_left()) % 60 == 0:
		turn_countdown.text = str(int(turn_timer.get_time_left())/60)+":"+str(int(turn_timer.get_time_left())%60)+"0"
	elif int(turn_timer.get_time_left()) % 60 < 10:
		turn_countdown.text = str(int(turn_timer.get_time_left())/60)+":0"+str(int(turn_timer.get_time_left())%60) 
	else: 
		turn_countdown.text = str(int(turn_timer.get_time_left())/60)+":"+str(int(turn_timer.get_time_left())%60)
	turn_ticker.text = "Player {n}'s turn!".format({"n":current_player._id})

# Checks troop count of next player, and switches to their turn if they can still play
func next_player():
	current_player = players.next() # Current player is now the next player
	if current_player._troops <= 0:
		next_player() # Ignore players with no troops left

func end_turn():
	if turn_timer.get_time_left() != 0:
		turn_timer.stop() 
	next_player()
	turn_timer.start(turn_time)
	tallies.text = ""
	var active_players: Array[Player]
	for i in players._players:
		if i._troops > 0:
			active_players.append(i)
	for player in active_players:
		tallies.text += "P{num}: {troops}\n".format({"num":player._id, "troops":troop_count})

func update_game_state(state: String) -> void:
	$MenuBar/Container/GameState.text = state

func _on_button_pressed():
	end_turn()

func _on_turn_timer_timeout():
	end_turn()

func _on_state_changer_pressed():
	change_state.emit()
