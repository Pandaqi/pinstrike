extends CanvasLayer
class_name Background

@export var bowling_ball : Ball
@export var fake_pin : Pin
@export var animate_ball := true

func _ready() -> void:
	if not animate_ball: return
	bowling_ball.roll_finished.connect(_on_roll_finished)
	_on_roll_finished()

func _on_roll_finished() -> void:
	var vp := get_viewport().get_visible_rect().size
	var go_horizontal := randf() <= 0.5
	var start_pos : Vector2
	var end_pos : Vector2
	var edge_margin := 512.0
	if go_horizontal:
		var rand_x := -edge_margin if randf() <= 0.5 else (vp.x+edge_margin)
		start_pos = Vector2(rand_x, randf_range(0, vp.y))
	else:
		var rand_y := -edge_margin if randf() <= 0.5 else (vp.y+edge_margin)
		start_pos = Vector2(randf_range(0, vp.x), rand_y)
	
	end_pos = start_pos
	if go_horizontal:
		if start_pos.x <= 0: end_pos.x += (vp.x + 2*edge_margin)
		else: end_pos.x -= (vp.x + 2*edge_margin)
	else:
		if start_pos.y <= 0: end_pos.y += (vp.y + 2*edge_margin)
		else: end_pos.y -= (vp.y + 2*edge_margin)
	
	var pin_pos := Vector2.ZERO
	var too_close_to_ball := true
	while too_close_to_ball:
		pin_pos = Vector2(randf_range(32, vp.x-32), randf_range(32, vp.y-32))
		too_close_to_ball = absf(pin_pos.x - start_pos.x) <= 64 or absf(pin_pos.y - start_pos.y) <= 64
	
	fake_pin.set_position(pin_pos)
	fake_pin.play_appear_animation()
	
	bowling_ball.roll_speed = randf_range(300.0, 600.0)
	bowling_ball.roll(start_pos, end_pos)
