extends PuzzleCommand
class_name CommandTurn

var lane_index := -1
var ball_number := -1
var generator : PuzzleGenerator

func _init(li:int, bn:int, gen:PuzzleGenerator):
	lane_index = li
	ball_number = bn
	generator = gen
	starts_new_turn = true

func do(cmds:PuzzleCommands) -> bool:
	var vis := cmds.visualizer as PuzzleVisualizer
	if vis: await vis.roll_bowling_ball(lane_index)
	
	var cur_lane := generator.lanes[lane_index]
	var cell := cur_lane.get_first_cell_hit()
	if not cell: return false
	
	var num_pins := cell.count()
	
	var invalid_move := (ball_number < num_pins) and generator.ball_too_weak_does_nothing
	if invalid_move:
		return false
	
	var is_perfect_hit := (ball_number == num_pins) and generator.ball_matches_pincount_remove_all
	
	var all_directions := CellData.get_all_directions()
	for dir in all_directions:
		var tp : CellData.PinType = cell.pins_by_direction.get(dir, CellData.PinType.NONE)
		if tp == CellData.PinType.NONE: continue
		if is_perfect_hit:
			await cmds.execute_command(CommandRemove.new(cell, dir))
			continue
		await cmds.execute_command(CommandScatter.new(cell, dir, generator))
	
	return true

# CommandScatters will undo themselves, we don't need to do anything
func undo(_cmds:PuzzleCommands) -> bool:
	return true

func matches(cmd:PuzzleCommand) -> bool:
	if not (cmd is CommandTurn): return false
	return lane_index == cmd.lane_index and ball_number == cmd.ball_number
