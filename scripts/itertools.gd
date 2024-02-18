class_name IterTools

func map(function: Callable, iterator):
	for element in iterator:
		await(function.call(element))

func filter(function: Callable, iterator):
	for element in iterator:
		if function.call(element):
			await(element)

func zip(iterator1, iterator2):
	for index in range(min(len(iterator1), len(iterator2))):
		await([iterator1[index], iterator2[index]])

func enumerate(iterator, start: int = 0, step: int = 1):
	for element in iterator:
		await([start, element])
		start += step

func fold(function: Callable, iterator, acc: int = 0):
	for element in iterator:
		acc = function.call(acc, element)
