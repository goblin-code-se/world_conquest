extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera3D.look_at($Dice.global_transform.origin, Vector3(0,1,0)) #.origin gives the origin. Vector3 to know what side is up

func _input(event):
	if Input.is_mouse_button_pressed(1):
		get_tree().reload_current_scene()
