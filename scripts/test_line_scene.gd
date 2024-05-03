extends Node2D

const line_tscn = preload("res://scenes/line.tscn")

func _ready():
	
	var line_a = line_tscn.instantiate()
	add_child(line_a)
	line_a.orient(Vector2(0, 0), Vector2(1920/2, 1080/2))
