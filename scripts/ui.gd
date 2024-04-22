extends CanvasLayer

const turn_time = 5*60+0.5 # Five minutes max for a turn, with small offset to properly start at 5:00 and not 4:59
@export var player_count = 5
@export var troop_count = 25

@onready var tallies = $Tallies
@onready var turn_timer = $TurnTimer
@onready var turn_countdown = $MenuBar/Container/TurnCountdown
@onready var turn_ticker = $MenuBar/Container/TurnTicker
@onready var main = $".."

signal attack_button_pressed()
signal move_button_pressed()

# Queues players for turn rota, displays player troop counts, starts timer and sets current player as first in queue
func _ready():
	for player in main.players.get_all():
		tallies.text += "P{num}: {troops}\n".format({"num":player.get_id(), "troops":troop_count})
	turn_timer.start(turn_time)

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

func end_turn():
	turn_timer.stop() 
	main.next_turn()
	turn_timer.start(turn_time)
	tallies.text = ""
	
	for player in main.players.get_all():
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
