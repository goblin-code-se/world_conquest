extends Node2D

var _normal_color: Color
var _width = 4.0
func orient(from: Vector2, to: Vector2):
	#
	#var adjacent = [Vector2(from.x, from.y), Vector2(from.x, to.y)]
	#var adjacent_len = to.y - from.y
	#print("Adj: " + str(adjacent_len))
	#var opposite = [Vector2(from.x, to.y), Vector2(to.x, to.y)]
	#var opposite_len = to.x - from.x
	#print("Opp: " + str(opposite_len))
	#
	## DBG
	##var line_a = Line2D.new()
	##get_parent().add_child.call_deferred(line_a)
	##line_a.add_point(adjacent[0])
	##line_a.add_point(adjacent[1])
	##line_a.width = 5.0
	##line_a.default_color = Color.BLUE
##
	##
	##var line_b = Line2D.new()
	##get_parent().add_child.call_deferred(line_b)
	##line_b.add_point(opposite[0])
	##line_b.add_point(opposite[1])
	##line_b.width = 5.0
	##line_b.default_color = Color.RED
	#
	##var line_c = Line2D.new()
	##get_parent().add_child.call_deferred(line_c)
	##line_c.add_point(from)
	##line_c.add_point(to)
	##line_c.width = 5.0
	##line_c.default_color = Color.GREEN
	#
	#
	## Basic pythagoras
	#var hyp_len = sqrt(abs(adjacent_len)**2 + abs(opposite_len)**2)
	#print(hyp_len)
	#
	#var line_angle = asin(abs(opposite_len) / abs(hyp_len))
	#print(rad_to_deg(line_angle))
	## sine(ang) = opp/hyp
	#$Sprite.rotation = -1.0 * line_angle
	#$CollisionArea.rotation = -1.0 * line_angle
	##if adjacent_len < 0.0 and opposite_len < 0.0:
		##rotation -= PI
	#
	## if y neg, flip y
	#if adjacent_len < 0.0:
		#$Sprite.rotation = PI - $Sprite.rotation
		#$CollisionArea.rotation = PI - $CollisionArea.rotation
	#if opposite_len < 0.0:
		#$Sprite.rotation *= -1.0
		#$CollisionArea.rotation *= -1.0
#
	#$Sprite.scale.x = _width/64.0
	#$Sprite.scale.y = hyp_len/64.0
	#$Sprite.position = from + (to/2.0)
	#
	#print($CollisionShape2D.shape)
	$CollisionShape2D.shape.a = from
	$CollisionShape2D.shape.b = to
	$CollisionShape2D.scale = Vector2(_width, _width)
	$Line2D.add_point(from)
	$Line2D.add_point(to)
	#$CollisionArea.scale.x = _width/64.0
	#$CollisionArea.scale.y = hyp_len/64.0
	#$CollisionArea.position = from + (to/2.0)
	
	
	#rotation = deg_to_rad(-45.)

func _on_mouse_entered():
	print("mouse enter")
	$Sprite.scale.x = (_width+2)/64.0
	_normal_color = $Line2D.default_color
	$Line2D.default_color = Color.RED

func _on_mouse_exited():
	print("mouse unenter")
	$Sprite.scale.x = _width/64.0
	$Line2D.default_color = _normal_color

func _on_input_event(event):
	print(event)

func _on_mouse_shape_entered(shape_idx):
	print("mouse enter")
