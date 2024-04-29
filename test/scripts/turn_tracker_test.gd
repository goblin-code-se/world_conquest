# GdUnit generated TestSuite
class_name TurnTrackerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://scripts/turn_tracker.gd'


func test_next() -> void:
	var arr: Array[Player] = []
	for i in range(1, 6):
		arr.append(Player.new(i, 25))
	var players = TurnTracker.new(arr)
	
	assert_int(players._pointer).is_equal(0)
	players.next()
	assert_int(players._pointer).is_equal(1)
	players.next()
	assert_int(players._pointer).is_equal(2)
	players.next()
	assert_int(players._pointer).is_equal(3)
	players.next()
	assert_int(players._pointer).is_equal(4)
	players.next()
	assert_int(players._pointer).is_equal(0)
	players.next()
