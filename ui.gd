extends CanvasLayer

@export var player_count = 5
@export var troop_count = 25

func _ready():
	$TurnTimer.start(5*60+0.5) # Five minutes max for a turn, with small offset to properly start at 5:00 and not 4:59
	for i in range(1, player_count+1):
		$Tallies.text += "Player {num}'s troops: {troops}\n".format({"num":i, "troops":troop_count})

# hoo boy, explanation time
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

func end_turn():
	$TurnTimer.stop() 
	# TODO: Switch player
	$TurnTimer.start(5*60+0.5)

func _on_button_pressed():
	end_turn()
