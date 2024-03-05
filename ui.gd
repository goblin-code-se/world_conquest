extends CanvasLayer

@export var player_count = 5
@export var troop_count = 25
var current_player
var players = CircQueue.new(player_count)

# Queues players for turn rota, displays player troop counts, starts timer and sets current player as first in queue
func _ready():
	for i in range(1, player_count+1):
		players.enqueue(Player.new(i, troop_count))
		$Tallies.text += "P{num}: {troops}\n".format({"num":i, "troops":troop_count})
	$TurnTimer.start(5*60+0.5) # Five minutes max for a turn, with small offset to properly start at 5:00 and not 4:59
	current_player = players.peek()

# div by 60 to get minutes, mod by 60 to get seconds
# first, checks if exactly to a minute, if so, then adds extra zero so that "5:0" is corrected to "5:00"
# second, checks if seconds remaining to a minute is less than 10, if so, then adds extra zero in another place such that "4:9" is corrected to "4:09"
func _process(_delta): 
	if int($TurnTimer.get_time_left()) % 60 == 0:
		$TurnCounterTexture/TurnCountdown.text = str(int($TurnTimer.get_time_left())/60)+":"+str(int($TurnTimer.get_time_left())%60)+"0"
	elif int($TurnTimer.get_time_left()) % 60 < 10:
		$TurnCounterTexture/TurnCountdown.text = str(int($TurnTimer.get_time_left())/60)+":0"+str(int($TurnTimer.get_time_left())%60) 
	else: 
		$TurnCounterTexture/TurnCountdown.text = str(int($TurnTimer.get_time_left())/60)+":"+str(int($TurnTimer.get_time_left())%60)
	$TurnTicker.text = "Player {n}'s turn!".format({"n":current_player.id})

# Checks troop count of next player, and switches to their turn if they can still play
func next_player():
	if current_player.troop_count <= 0:
		players.dequeue() # Remove player from game permanently if no troops left
		current_player = players.peek()
	var next = players.dequeue()
	players.enqueue(next) # Re-add to back of queue
	current_player = players.peek() # Current player is now the next player

func end_turn():
	if $TurnTimer.get_time_left() != 0:
		$TurnTimer.stop() 
	next_player()
	$TurnTimer.start(5*60+0.5)

func _on_button_pressed():
	end_turn()

func _on_turn_timer_timeout():
	end_turn()
