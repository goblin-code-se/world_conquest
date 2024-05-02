class_name Redis extends Resource

var data = {
	"test": "test"
}

func _set(property, value):
	data[property] = value

func _get(property):
	return data[property]
