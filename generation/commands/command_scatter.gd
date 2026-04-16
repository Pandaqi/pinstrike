extends PuzzleCommand
class_name CommandScatter

var cell : CellData
var dir : CellData.Direction
var generator : PuzzleGenerator

var type_removed : CellData.PinType
var neighbor_used : CellData

func _init(c:CellData, d:CellData.Direction, gen:PuzzleGenerator):
	cell = c
	dir = d
	generator = gen

func do(cmds:PuzzleCommands) -> bool:
	var vis := cmds.visualizer as PuzzleVisualizer
	
	type_removed = cell.get_pin_at(dir)
	cell.remove_pin(dir)
	
	if vis:
		await vis.create_scatter_tween(cell, dir)
	
	# at the edge; we've already been removed; nothing more to do
	var nb := cell.get_opposite_neighbor(dir)
	if not nb: return true
	
	# hits an existing pin
	var has_pin := nb.has_pin_at(dir)
	if has_pin:
		await cmds.execute_command(CommandRemove.new(nb, dir))
		return true
	
	neighbor_used = nb
	nb.add_pin(type_removed, dir)
	return true

func undo(cmds:PuzzleCommands) -> bool:
	# scatter ended up just being a removal, don't do anything more
	if not type_removed: return true
	cell.add_pin(type_removed, dir)
	
	var vis := cmds.visualizer as PuzzleVisualizer
	if vis: vis.play_pin_appear_tween(cell, dir)
	
	if not neighbor_used: return true
	neighbor_used.remove_pin(dir)
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandScatter): return false
	return cell == cmd.cell and dir == cmd.dir
