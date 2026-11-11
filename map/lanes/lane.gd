extends Node2D
class_name Lane

var data : LaneData

var hovering := false
@export var hover_line_color := Color.RED

@export var cell_scene : PackedScene
var cells : Array[Cell] = []

@export var area : Area2D
@export var col_shape : CollisionShape2D

@export var lines : Node2D
@export var line_left : Line2D
@export var line_right : Line2D

@export var center_marker : Node2D

signal clicked()
signal hover_changed(h:bool)

func _ready() -> void:
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func sync_to_data(ld:LaneData) -> void:
	data = ld
	_on_data_changed()

func _on_data_changed() -> void:
	# create all cells
	for cell_data in data.cells:
		var cell : Cell = cell_scene.instantiate()
		cell.set_position(PuzzleVisualizer.get_cell_position(cell_data))
		cells.append(cell)
		add_child(cell)
		cell.sync_to_data(cell_data)
	
	# update shape to match
	var size := get_size()
	var shape := RectangleShape2D.new()
	shape.size = size
	col_shape.set_position(0.5*size)
	col_shape.shape = shape
	
	line_left.points = [Vector2.ZERO, Vector2(0,size.y)]
	line_right.points = [Vector2(size.x, 0), size]
	
	center_marker.set_position(0.5 * size)

func on_appear() -> void:
	for cell in cells:
		cell.on_appear()

func _on_input_event(_vp:Node, ev:InputEvent, _sidx:int) -> void:
	if not (ev is InputEventMouseButton or ev is InputEventScreenTouch): return
	if ev.is_pressed(): return
	clicked.emit()

func _on_mouse_entered() -> void:
	hovering = true
	lines.z_index = 1024
	line_left.default_color = hover_line_color
	line_right.default_color = hover_line_color
	hover_changed.emit(true)

func _on_mouse_exited() -> void:
	hovering = false
	lines.z_index = 0
	line_left.default_color = Color.BLACK
	line_right.default_color = Color.BLACK
	hover_changed.emit(false)

func get_size() -> Vector2:
	return Vector2(PuzzleVisualizer.cell_size) * Vector2(1, count())

func count() -> int:
	return cells.size()

func count_pins() -> int:
	return data.count_pins()

func get_position_of(cell:CellData) -> Vector2:
	var cell_idx := data.cells.find(cell)
	if cell_idx == -1: return get_end_position()
	var real_cell := cells[cell_idx]
	return real_cell.global_position

func get_end_position() -> Vector2:
	return get_position_of(data.cells.front()) + Vector2.UP * PuzzleVisualizer.cell_size.y

func get_start_position() -> Vector2:
	return get_position_of(data.cells.back()) + Vector2.DOWN * PuzzleVisualizer.cell_size.y
