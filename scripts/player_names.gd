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
			players[i]["ai_difficulty"] = difficulty
			
		redis.data["players"] = players
		print(redis.data)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
