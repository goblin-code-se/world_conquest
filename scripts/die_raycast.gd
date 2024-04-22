extends RayCast3D

@export var opposite_side: int

func _ready():
	add_exception(owner) # seems like this prevents the raycast from preventing the dice itself. We only want it to detect the floor (and the walls in the example but idk)
