extends Control

var redis = preload("res://redis.tres")
func _ready():
	var winner = redis.data["winner"]
	$CenterContainer/RichTextLabel.text = "[rainbow freq=0.5 val=0.8 sat=0.8][wave][b][u]" + winner._name + " WINS[/u][/b][/wave][/rainbow]"
#  freq=1.0 sat=0.8 val=0.8
