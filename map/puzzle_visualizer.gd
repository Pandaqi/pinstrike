extends Node2D
class_name PuzzleVisualizer

var commands : PuzzleCommands
var generator : PuzzleGenerator
var bounds : Rect2

var turn := -1
var busy := false
var lane_hovered : Lane

@export var bowling_ball : Ball
@export var bowling_ball_hover : Ball
@export var fake_pin : Pin

@export var ball_selection : BallSelection
@export var audio_strike : AudioStreamPlayer2D

@export var lane_scene : PackedScene
var lanes : Array[Lane]

signal turn_changed(t:int)
signal loading_completed()

static var cell_size := Vector2i(256, 256)

static func get_cell_position(cell_data:CellData) -> Vector2:
	return Vector2(0.5, cell_data.pos.y + 0.5) * Vector2(cell_size)

static func show_number_on_balls() -> bool:
	return PuzzleSettings.get_difficulty_property("ball_matches_pincount_remove_all") or PuzzleSettings.get_difficulty_property("ball_too_weak_does_nothing")

func _ready() -> void:
	turn_changed.connect(ball_selection._on_turn_changed)

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	
	lanes = []
	var counter := 0
	for lane_data in gen.lanes:
		var lane : Lane = lane_scene.instantiate()
		lane.set_position(Vector2(counter * cell_size.x, 0))
		counter += 1
		
		lane.clicked.connect(_on_lane_clicked, CONNECT_APPEND_SOURCE_OBJECT)
		lane.hover_changed.connect(_on_lane_hovered, CONNECT_APPEND_SOURCE_OBJECT)
		
		lanes.append(lane)
		add_child(lane)
		lane.sync_to_data(lane_data)
	
	bounds = Rect2(Vector2.ZERO, generator.grid.size * cell_size)
	
	commands = PuzzleCommands.new()
	commands.prepare_for_play(self)
	commands.set_solution(generator.solution)
	
	ball_selection.set_solution(generator.solution)
	
	commands.do_finished.connect(_on_commands_do_finished)
	commands.undo_finished.connect(_on_commands_undo_finished)
	set_turn(0)
	
	fake_pin.reset()
	
	for lane in lanes:
		lane.on_appear()
	
	loading_completed.emit()
	PuzzleFramework.start_puzzle()

func refresh_turn() -> void:
	set_turn(commands.count())

func set_turn(t:int) -> void:
	var max_turns := generator.solution.size() - 1
	var no_pins_left := count_pins() <= 0
	var game_is_over := (t > max_turns or no_pins_left)
	if game_is_over:
		goto_game_over(no_pins_left)
		return
	
	turn = clampi(t, 0, max_turns)
	turn_changed.emit(turn)

func count_pins() -> int:
	var sum := 0
	for lane in lanes:
		sum += lane.count_pins()
	return sum

func _physics_process(_dt:float) -> void:
	visualize_hovered_lane()

func visualize_hovered_lane() -> void:
	if not lane_hovered: 
		bowling_ball_hover.hide()
		return
	bowling_ball_hover.show()
	bowling_ball_hover.set_position(lane_hovered.get_start_position())
	bowling_ball_hover.modulate.a = 0.15 if bowling_ball.rolling else 1.0

func play_pin_disappear_tween(cell_data:CellData, dir:CellData.Direction) -> void:
	var cell := get_cell_from_data(cell_data)
	var pin := cell.get_pin_at(dir)
	pin.play_disappear_animation(2.0)
	await pin.animation_finished

func play_pin_appear_tween(cell_data:CellData, dir:CellData.Direction) -> void:
	var cell := get_cell_from_data(cell_data)
	var pin := cell.get_pin_at(dir)
	pin.play_appear_animation()
	await pin.animation_finished

func get_current_ball_number() -> int:
	return generator.solution[turn].ball_number

func _on_lane_hovered(hovering:bool, lane:Lane) -> void:
	if lane_hovered == lane and not hovering:
		lane_hovered = null
	if hovering:
		lane_hovered = lane

func _on_lane_clicked(lane:Lane) -> void:
	if commands.is_busy() or busy: return
	
	busy = true
	
	var lane_index := lane.data.index
	var cmd := CommandTurn.new(lane_index, get_current_ball_number(), generator)
	commands.execute_command(cmd)
	
	busy = false

func _on_commands_do_finished(cmd:PuzzleCommand) -> void:
	if not (cmd is CommandTurn): return
	refresh_turn()

func _on_commands_undo_finished(_cmds:Array[PuzzleCommand]) -> void:
	refresh_turn()
	
	#@TODO: roll the bowling ball in reverse?

func goto_game_over(we_won:bool) -> void:
	PuzzleFramework.finish_puzzle(we_won)

func roll_bowling_ball(lane_index:int) -> void:
	# bowling_ball.set_number(get_current_ball_number())
	bowling_ball.roll_over_lane(lanes[lane_index])
	await bowling_ball.roll_finished
	if bowling_ball.roll_hits_something: 
		PuzzleAudio.play_audio_nice(audio_strike)

func get_cell_from_data(cell_data:CellData) -> Cell:
	return lanes[cell_data.pos.x].cells[cell_data.pos.y]

func create_scatter_tween(cell_data:CellData, dir:CellData.Direction) -> void:
	var vec := CellData.convert_direction_to_vector(dir)
	var cell := get_cell_from_data(cell_data)
	var start_pos := cell.get_position_of_pin_at(dir)
	var end_pos := start_pos + Vector2(vec * cell_size)
	
	fake_pin.show()
	fake_pin.set_position(start_pos)
	fake_pin.sprite.set_rotation(0) # @NOTE: we rotate the sprite because the pin is anchored at the bottom-Y, so rotating the whole thing would be really wonky
	
	fake_pin.match_look_of(cell.get_pin_at(dir))
	fake_pin.play_knock_sound(dir)
	
	var end_rotation := (2 * PI)
	if vec.x < 0: end_rotation *= -1
	
	var duration := randf_range(0.45, 0.5)
	duration /= PuzzleSettings.get_value("pin_animation_speed")
	
	var tw := get_tree().create_tween()
	tw.tween_property(fake_pin, "position", end_pos, duration)
	tw.parallel().tween_property(fake_pin.sprite, "rotation", end_rotation, duration)
	tw.tween_callback(fake_pin.hide)
	await tw.finished
	
