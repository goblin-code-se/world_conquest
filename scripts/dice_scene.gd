extends Node3D

var attacking_die = true
var count = 5
var internal_results = []
var broadcast
signal results

# Called when the node enters the scene tree for the first time.
#func _ready():
	#for i in range(count):
		#add_die()
		#
	#show_result(await results)
	
func _ready():
	$ResultsShowTimer.timeout.connect(func(): results.emit(internal_results))
	
func reset(attacking, count_input, broadcast_signal):
	broadcast = broadcast_signal
	$Results.visible = false
	internal_results = []
	
	count = count_input
	attacking_die = attacking
	for i in range(count):
		add_die()
		
	await results
	remove_die()

func add_die():
	var die;
	if attacking_die:
		die = preload("res://scenes/red_die.tscn").instantiate()
	else:
		die = preload("res://scenes/blue_die.tscn").instantiate()
	
	die.position = Vector3(randf()/3, 1, randf()/3)
	die.add_to_group("Dice")
	add_child(die)
	
	# Add watcher functions to each die
	die.result.connect(add_result.bind())

func remove_die():
	for child in get_children():
		if child.is_in_group("Dice"):
			child.queue_free()

func show_result(results):
	var string = "";
	results.sort()
	results.reverse()
	for result in results:
		string += str(result) + " "
	
	$Results.text = string.rstrip(" ")
	if attacking_die:
		$Results.modulate = Color(231.0/255.0, 0.0, 34.0 /255.0, 1.0)
	else:
		$Results.modulate = Color(0.0, 113.0/255.0, 254.0/255.0, 1.0)
	$Results.visible = true

# Runs when die has finished rolling
func add_result(result):
	internal_results.append(result)
	if internal_results.size() == count:
		if null in internal_results:
			broadcast.emit("Congratulations! You found an edge case where a die rolled Null. \nAll nulls will be replaced with 6. Congrats!")
			internal_results = internal_results.map(func(item):
				if item == null:
					return 6
				else:
					return item
			)
		show_result(internal_results)
		$ResultsShowTimer.start(1.5)
