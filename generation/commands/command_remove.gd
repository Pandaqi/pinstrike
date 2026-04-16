extends PuzzleCommand
class_name CommandRemove

var cell : CellData
var dir : CellData.Direction
var type_removed : CellData.PinType

func _init(c:CellData, d:CellData.Direction):
	cell = c
	dir = d

func do(cmds:PuzzleCommands) -> bool:
	type_removed = cell.get_pin_at(dir)
	var vis := cmds.visualizer as PuzzleVisualizer
	if vis: await vis.play_pin_disappear_tween(cell, dir)
	cell.remove_pin(dir)
	return true

func undo(cmds:PuzzleCommands) -> bool:
	cell.add_pin(type_removed, dir)
	var vis := cmds.visualizer as PuzzleVisualizer
	if vis: vis.play_pin_appear_tween(cell, dir)
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandRemove): return false
	return cell == cmd.cell and dir == cmd.dir
