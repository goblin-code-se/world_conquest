extends CanvasLayer

@export var player_count = 5
@export var troop_count = 25

func _ready():
	$TurnTimer.start(500) # Five minutes max for a turn
	for i in range(0, player_count):
		$Tallies.text += "Player {num}'s troops: {troops}\n".format({"num":i, "troops":troop_count})

func _process(_delta):
	$TurnCounterTexture.get_child(0).text = str($TurnTimer.get_time_left()/60)+":"+str($TurnTimer.get_time_left()%60.0) # div by 60 to get minutes, mod by 60 to get mins

func end_turn():
	$TurnTimer.stop()

func _on_button_pressed():
	end_turn()
