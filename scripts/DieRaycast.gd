extends RayCast3D

@export var opposite_side: int


# Called when the node enters the scene tree for the first time.
func _ready():
	add_exception(owner) # seems like this prevents the raycast from preventing the dice itself. We only want it to detect the floor (and the walls in the example but idk)
	#if is_colliding():
		#print('colliding')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
