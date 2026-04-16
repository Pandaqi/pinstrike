extends Node2D
class_name BallSelection

@export var ball_scene : PackedScene
var balls : Array[Ball] = []
var cur_selected : Ball

var item_size := Vector2(64.0, 64.0)

func set_solution(solution:Array[PuzzleCommand]) -> void:
	# create all balls (with right configuration)
	for i in range(solution.size()):
		var b : Ball = ball_scene.instantiate()
		balls.append(b)
		add_child(b)
		b.set_size(item_size)
		b.set_number(solution[i].ball_number)
	
	# start off with none selected
	cur_selected = null
	for ball in balls:
		ball.unhighlight()
	
	# start listening to viewport changes + init call for placement
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()

func _on_size_changed() -> void:
	refresh()

func count() -> int:
	return balls.size()

func refresh() -> void:
	var offset := -0.5 * (count() - 1) * item_size.x * Vector2.RIGHT
	
	for i in range(count()):
		var pos := offset + i * item_size.x * Vector2.RIGHT
		balls[i].set_position(pos)
	
	var vp := get_viewport_rect().size
	set_position(Vector2(0.5*vp.x, 0.66*item_size.y))

func _on_turn_changed(turn:int) -> void:
	if cur_selected: cur_selected.unhighlight()
	cur_selected = balls[turn]
	cur_selected.highlight()
