extends HBoxContainer

func _process(_delta):
	$OptionButton.disabled = not $CheckBox.button_pressed
		
