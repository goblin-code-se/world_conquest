extends Control

var redis = preload("res://redis.tres")

func _ready():
	$Centerer/MenuButtons/NormalGame.pressed.connect(func(): 
		redis.data["mission_mode"] = false
		get_tree().change_scene_to_file("res://scenes/player_names.tscn")
	)
	$Centerer/MenuButtons/MissionGame.pressed.connect(func(): 
		redis.data["mission_mode"] = true
		get_tree().change_scene_to_file("res://scenes/player_names.tscn")
	)
	$Centerer/MenuButtons/HBoxContainer/BoardEditor.pressed.connect(func(): 
		get_tree().change_scene_to_file("res://scenes/board_editor.tscn")
		# todo, signal to main that mission mode is enabled. unsure how to do this
	)
	$Centerer/MenuButtons/Quit.pressed.connect(func(): get_tree().quit())
	# todo, other buttons
