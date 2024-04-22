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

signal attack_button_pressed()
signal move_button_pressed()

# Queues players for turn rota, displays player troop counts, starts timer and sets current player as first in queue
func _ready():
	for i in range(1, player_count+1):
		players.enqueue(Player.new(i, troop_count))
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

# Checks troop count of next player, and switches to their turn if they can still play
func next_player():
	if current_player._troops <= 0:
		players.dequeue() # Remove player from game permanently if no troops left
		current_player = players.peek()
	var next = players.dequeue()
	players.enqueue(next) # Re-add to back of queue
	current_player = players.peek() # Current player is now the next player

func end_turn():
	if turn_timer.get_time_left() != 0:
		turn_timer.stop() 
	next_player()
	turn_timer.start(turn_time)
	tallies.text = ""
	
	for player in players._players:
		tallies.text += "P{num}: {troops}\n".format({"num":player._id, "troops":troop_count})

func update_turn_ticker(player: int) -> void:
	$MenuBar/Container/TurnTicker.text = "Player {0}'s turn!".format([player])

func update_game_state(state: String) -> void:
	$MenuBar/Container/GameState.text = state

func update_troop_count(troop_count: int) -> void:
	$MenuBar/Container/TroopCount.text = "Troop count: {0}".format([troop_count])

func _on_button_pressed():
	end_turn()

func _on_turn_timer_timeout():
	end_turn()

func _on_attack_button_pressed():
	attack_button_pressed.emit()

func _on_move_button_pressed():
	move_button_pressed.emit()
