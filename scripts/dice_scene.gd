extends Node3D
func _input(event):
	if Input.is_mouse_button_pressed(1):
		get_tree().reload_current_scene()
