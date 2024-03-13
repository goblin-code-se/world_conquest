extends RigidBody3D
@export var rotation_power: float = 10.0
@onready var result: int


#
func find_orientation_value():	#compares the rotation to the global 'up' and returns the value of the side that is pointed up
	var basis = transform.basis
	for vector_value in [[basis.x.normalized(),5],[basis.y.normalized(),6],[basis.z.normalized(),4]]:
		if (0.9< vector_value[0].dot(Vector3(0,1,0)) and vector_value[0].dot(Vector3(0,1,0)) <1.1):
			return(vector_value[1])
		elif (-0.9> vector_value[0].dot(Vector3(0,1,0)) and vector_value[0].dot(Vector3(0,1,0)) >-1.1):
			return(7-vector_value[1])


# Called when the node enters the scene tree for the first time.
func _ready():
	transform.basis = transform.basis.rotated(Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1)).normalized(), randf_range(-PI,PI))
	set_axis_velocity(Vector3(0,0,2-randf()))
