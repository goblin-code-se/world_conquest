extends CanvasLayer

@export var player_count = 5
@export var troop_count = 25

func _ready():
	$TurnTimer.start(5*60+0.5) # Five minutes max for a turn, with small offset to properly start at 5:00 and not 4:59
	for i in range(0, player_count):
		$Tallies.text += "Player {num}'s troops: {troops}\n".format({"num":i, "troops":troop_count})

func _process(_delta):
	$TurnCounterTexture/TurnCountdown.text = str($TurnTimer.get_time_left()/60)+":"+str(int($TurnTimer.get_time_left())%60) # div by 60 to get minutes, mod by 60 to get mins

func end_turn():
	$TurnTimer.stop() 
	# TODO: Switch player
	$TurnTimer.start(5*60+0.5)

func _on_button_pressed():
	end_turn()
