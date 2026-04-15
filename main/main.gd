extends Node2D
class_name Main

var gen : PuzzleGenerator
@export var vis : PuzzleVisualizer
@export var cam : PuzzleCamera

func _ready() -> void:
	gen = PuzzleGenerator.new()
	gen.generate()
	vis.visualize(gen)
	
	cam.set_target(vis.bounds)
	
	print("SOLUTION | ")
	for cmd in gen.solution:
		print(cmd.lane_index)
