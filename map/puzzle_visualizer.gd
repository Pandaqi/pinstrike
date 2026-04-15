extends Node2D
class_name PuzzleVisualizer

var generator : PuzzleGenerator
var bounds : Rect2

@export var cell_scene : PackedScene
var cells : Array[Cell] = []
var cell_size := Vector2i(128, 128)

func visualize(gen:PuzzleGenerator) -> void:
	generator = gen
	
	cells = []
	for cell_data in generator.grid.get_cells():
		var cell : Cell = cell_scene.instantiate()
		cell.set_position(Vector2(cell_data.pos * cell_size) + 0.5 * Vector2(cell_size))
		cells.append(cell)
		add_child(cell)
		cell.sync_to_data(cell_data)
	
	bounds = Rect2(Vector2.ZERO, generator.grid.size * cell_size)
