extends CanvasLayer

@export var player_count = 5
@export var troop_count = 25
var current_player: Player
var players = Queue.new()

# Queues players for turn rota, displays player troop counts, starts timer and sets current player as first in queue
func _ready():
	for i in range(1, player_count+1):
		players.enqueue(Player.new(i, troop_count))
		$Board/Tallies.text += "P{num}: {troops}\n".format({"num":i, "troops":troop_count})
	$Board/TurnTimer.start(5*60+0.5) # Five minutes max for a turn, with small offset to properly start at 5:00 and not 4:59
	current_player = players.peek()

# div by 60 to get minutes, mod by 60 to get seconds
# first, checks if exactly to a minute, if so, then adds extra zero so that "5:0" is corrected to "5:00"
# second, checks if seconds remaining to a minute is less than 10, if so, then adds extra zero in another place such that "4:9" is corrected to "4:09"
func _process(_delta): 
	if int($Board/TurnTimer.get_time_left()) % 60 == 0:
		$Board/MenuBarTexture/TurnCountdown.text = str(int($Board/TurnTimer.get_time_left())/60)+":"+str(int($Board/TurnTimer.get_time_left())%60)+"0"
	elif int($Board/TurnTimer.get_time_left()) % 60 < 10:
		$Board/TurnCountdown.text = str(int($Board/TurnTimer.get_time_left())/60)+":0"+str(int($Board/TurnTimer.get_time_left())%60) 
	else: 
		$Board/MenuBarTexture/TurnCountdown.text = str(int($Board/TurnTimer.get_time_left())/60)+":"+str(int($Board/TurnTimer.get_time_left())%60)
	$Board/TurnTicker.text = "Player {n}'s turn!".format({"n":current_player._id})

# Checks troop count of next player, and switches to their turn if they can still play
func next_player():
	if current_player._troops <= 0:
		players.dequeue() # Remove player from game permanently if no troops left
		current_player = players.peek()
	var next = players.dequeue()
	players.enqueue(next) # Re-add to back of queue
	current_player = players.peek() # Current player is now the next player

func end_turn():
	if $Board/TurnTimer.get_time_left() != 0:
		$Board/TurnTimer.stop() 
	next_player()
	$Board/TurnTimer.start(5*60+0.5)
	$Board/Tallies.text = ""
	for player in players._players:
		$Board/Tallies.text += "P{num}: {troops}\n".format({"num":player._id, "troops":troop_count})

func _on_button_pressed():
	end_turn()

func _on_turn_timer_timeout():
	end_turn()
