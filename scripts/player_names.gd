extends Control

var redis = preload("res://redis.tres")
func _ready():
	$CenterContainer/VBoxContainer/Button.pressed.connect(func(): 
		
		var players = {}
		for i in range(1,6):
			
			players[i] = {}
			var node = $CenterContainer/VBoxContainer.get_node(str(i))
			
			var name = node.get_node("LineEdit").text
			if name.is_empty():
				name = node.get_node("LineEdit").placeholder_text
			players[i]["name"] = name
			
			var is_ai = node.get_node("CheckBox").button_pressed
			players[i]["ai"] = is_ai
			
			var difficulty = node.get_node("OptionButton").get_selected_id()
			var diff_percent = [1.0, 0.75, 0.5, 0.25, 0.0][difficulty]

			players[i]["ai_difficulty"] = diff_percent
			
		redis.data["players"] = players
		
		var ai_thought_time = $CenterContainer/VBoxContainer/AIThought/OptionButton.get_selected_id()
		redis.data["ai_thought_time"] = [0.7, 0.1, 0.02, 0.000000000000001][ai_thought_time]
		
		var dice_roll_speed = $CenterContainer/VBoxContainer/DiceRolls/OptionButton.get_selected_id()
		redis.data["fake_rolls"] = dice_roll_speed == 1
		
		var turn_time = $"CenterContainer/VBoxContainer/Turn Time/SpinBox".value
		redis.data["turn_time"] = turn_time*60+0.5
		
		print(redis.data)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
