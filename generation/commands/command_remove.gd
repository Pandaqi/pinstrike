extends PuzzleCommand
class_name CommandRemove

var cell : CellData
var dir : CellData.Direction
var type_removed : CellData.PinType

func _init(c:CellData, d:CellData.Direction):
	cell = c
	dir = d

func do(_cmds:PuzzleCommands) -> bool:
	type_removed = cell.get_pin_at(dir)
	cell.remove_pin(dir)
	return true

func undo(_cmds:PuzzleCommands) -> bool:
	cell.add_pin(type_removed, dir)
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandRemove): return false
	return cell == cmd.cell and dir == cmd.dir
