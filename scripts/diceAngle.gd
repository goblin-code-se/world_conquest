extends RigidBody3D
@export var rotation_power: float = 10.0
@export var rotation_minimum: float = 2.0
signal result;

# Returns random float between +-rotation_minimum and +-rotation_power
func random_rotation():
	randomize()
	return randf_range(rotation_minimum,rotation_power) * [1,-1].pick_random()

#compares the rotation to the global 'up' and returns the value of the side that is pointed up
#no more collision checks
func find_orientation_value():
	var basis = transform.basis
	for vector_value in [[basis.x.normalized(),5],[basis.y.normalized(),6],[basis.z.normalized(),4]]:
		if (0.9< vector_value[0].dot(Vector3(0,1,0)) and vector_value[0].dot(Vector3(0,1,0)) <1.1):
			return(vector_value[1])
		elif (-0.9> vector_value[0].dot(Vector3(0,1,0)) and vector_value[0].dot(Vector3(0,1,0)) >-1.1):
			return(7-vector_value[1])

# Called when the node enters the scene tree for the first time.
func _ready():
	set_angular_velocity(Vector3(random_rotation(),random_rotation(),random_rotation()))
	
	while (get_angular_velocity().length() > 0.1):
		await get_tree().create_timer(0.2).timeout
	
	# Returns die value in signal
	result.emit(find_orientation_value())
