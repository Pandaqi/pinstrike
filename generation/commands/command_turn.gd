extends PuzzleCommand
class_name CommandTurn

var lane_index := -1
var generator : PuzzleGenerator

func _init(li:int, gen:PuzzleGenerator):
	lane_index = li
	generator = gen

func do(cmds:PuzzleCommands) -> bool:
	return true

func undo(cmds:PuzzleCommands) -> bool:
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandTurn): return false
	return false
