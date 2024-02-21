extends RigidBody3D

# Assuming you have a RayCast3D node for each face under a node named "Raycast"
@onready var raycasts = $Raycast.get_children()

'''Array to store the results of the dice.
This should later be expanded:
	Results should be saved in the main scene, with each of the dices exporting their individual result to'''
var results = []
'''Could use populating the results array correctly for unit testing.
If it wasnt correctly populated, show error message + roll again.
If after x amount of tries it still doesnt work -> Give up
Either amount of tries or until the turn for the time finishes sounds good to me.'''

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	# Implementation of random strength for rolling the dice at the start of the animation
	var x = randf_range(-10,10)
	var y = randf_range(-10,10)
	var z = randf_range(-10,10)
	
	set_angular_velocity(Vector3(x,y,z))
	
	# Wait for dice to stop rolling.
	await get_tree().create_timer(6.0).timeout
	
	# Loop over each of the raycasts to check which is colliding with the board.
	for raycast in raycasts:
		# if a raycast is colliding with the board, the opposite side is the result.
		if raycast.is_colliding():
			results.append(raycast.opposite_side)
			print(results)
	
