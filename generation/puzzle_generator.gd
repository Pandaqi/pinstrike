class_name PuzzleGenerator

var grid : PuzzleGrid
var lanes : Array[LaneData]
var solution : Array[CommandTurn] = []

var num_lanes_bounds := Vector2i(3,5)
var lane_length_bounds := Vector2i(3,5)
var num_turns_bounds := Vector2i(3,6)
var allow_diagonals := false

var directions_orthogonal : Array[CellData.Direction] = [CellData.Direction.RIGHT, CellData.Direction.BOTTOM, CellData.Direction.LEFT, CellData.Direction.TOP]
var directions_diagonal : Array[CellData.Direction] = [CellData.Direction.TOP_RIGHT, CellData.Direction.TOP_LEFT, CellData.Direction.BOTTOM_RIGHT, CellData.Direction.BOTTOM_LEFT]

func generate() -> void:
	create_grid()
	take_turns()
	clean_up()

func create_grid() -> void:
	# first create the regular grid
	var grid_size := Vector2i(randi_range(num_lanes_bounds.x, num_lanes_bounds.y), randi_range(lane_length_bounds.x, lane_length_bounds.y))
	grid = PuzzleGrid.new()
	grid.creation_callback = func(pos:Vector2i): return CellData.new(pos)
	grid.create(grid_size)
	
	# cache some important info for generation later
	# (so we only need to calculate it once here instead of over and over)
	for elem in grid.get_cells():
		elem.calculate_neighbor_data()
	
	# then collect columns into lanes as that makes the code/logic much easier and more readable
	lanes = []
	for i in range(grid_size.x):
		var column : Array[CellData] = []
		column.assign(grid.get_column(i))
		var new_lane := LaneData.new(i, column)
		lanes.append(new_lane)

func take_turns() -> void:
	solution = []
	
	var directions : Array[CellData.Direction] = directions_orthogonal.duplicate(false)
	if allow_diagonals: directions += directions_diagonal
	
	var num_turns := randi_range(num_turns_bounds.x, num_turns_bounds.y)
	for i in range(num_turns):
		var valid_turns := get_all_valid_turns()
		if valid_turns.size() <= 0: break
		
		var rand_index := randi() % mini(valid_turns.size(), 3)
		var rand_cell := valid_turns[rand_index]
		
		# find all options for "growing" the cell/puzzle ...
		var growth_options : Array[GrowthOption] = []
		for dir in directions:
			# if at the edge, we can always place a pin there (it would be removed if hit with ball)
			if pin_is_at_edge(rand_cell, dir):
				var new_option_1 := GrowthOption.new(GrowthOption.Type.PLACE, rand_cell, dir)
				growth_options.append(new_option_1)
				continue
			
			# if there's a pin on the opposite side, we can attract it to our position
			var pin_opposite := rand_cell.get_pin_on_opposite_neighbor(dir)
			print(pin_opposite)
			var nb_opposite := rand_cell.get_opposite_neighbor(dir)
			var dir_opposite := CellData.get_dir_opposite_to(dir)
			if pin_opposite != CellData.PinType.NONE:
				var new_option_2 := GrowthOption.new(GrowthOption.Type.ATTRACT, rand_cell, dir, nb_opposite, dir_opposite)
				growth_options.append(new_option_2)
				continue
			
			# otherwise, it means we are empty, the other side is empty, so we can place a pin on BOTH locations
			var double_placement_allowed := dir != CellData.Direction.BOTTOM
			if double_placement_allowed:
				var new_option_3 := GrowthOption.new(GrowthOption.Type.PLACE, rand_cell, dir, nb_opposite, dir_opposite)
				growth_options.append(new_option_3)
		
		var can_grow := growth_options.size() > 0
		if not can_grow: continue
		
		# ... then apply a random set of them
		var num_options_to_pick := randi_range(1, growth_options.size() - 1)
		growth_options.shuffle()
		var options := growth_options.slice(0, num_options_to_pick)
		for option in options:
			option.apply()
		
		# and finally remember what we did
		var cur_lane := lanes[rand_cell.pos.x]
		cur_lane.strike_cell(rand_cell)
		solution.append(CommandTurn.new(cur_lane.index, self))
	
	# don't forget that we generated backward and need to reverse the solution!
	solution.reverse()

func pin_is_at_edge(cell:CellData, dir:CellData.Direction) -> bool:
	var pos := cell.pos
	var vec := CellData.convert_direction_to_vector(dir)
	if pos.x == 0 and vec.x < 0: return true
	if pos.x == (grid.size.x - 1) and vec.x > 0: return true
	if pos.y == 0 and vec.y < 0: return true
	if pos.y == (grid.size.y - 1) and vec.y > 0: return true
	return false

func get_all_valid_turns() -> Array[CellData]:
	var arr : Array[CellData] = []
	
	# first, we only want cells that should be reachable with a throw
	# that is, they must be in FRONT OF cells we already struck earlier
	for lane in lanes:
		arr += lane.get_cells_before_first_struck()
	
	# then, we can only do this with a cell that's empty OR all its pins are against the edge
	arr = arr.filter(func(c:CellData): return c.is_empty())
	
	# finally, we prefer cells with neighbors that have pins (for maximum interaction)
	# first, cache this calculation to prevent doing it over and over, then sort by it
	for elem in arr:
		elem.calculate_neighbor_pins()
	arr.sort_custom(func(a:CellData, b:CellData): return a.neighbor_pins_pointed_at_us > b.neighbor_pins_pointed_at_us)
	
	return arr

func clean_up() -> void:
	pass # @TODO
