class_name CircQueue

var items

func _init(num):
	items = []

func enqueue(item):
	items.push_back(item)

func dequeue():
	return items.pop_front()

func peek():
	return items.front()
