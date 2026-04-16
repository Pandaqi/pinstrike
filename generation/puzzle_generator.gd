class_name PuzzleGenerator

var grid : PuzzleGrid
var lanes : Array[LaneData]
var solution : Array[PuzzleCommand] = []

var num_lanes_bounds := Vector2i(3,3)
var lane_length_bounds := Vector2i(2,4)
var num_turns_bounds := Vector2i(3,6)

var allow_diagonals := false
var remove_pins_if_already_occupied := false

var ball_keeps_going_after_hit := false # @TODO

var ball_too_weak_does_nothing := false # a ball with number < pincount simply has no effect
var ball_matches_pincount_remove_all := false # a ball with number = pincount will remove all pins there

var perfect_number_probability := 0.35
var max_grow_options_applied := 5

var directions_orthogonal : Array[CellData.Direction] = [CellData.Direction.RIGHT, CellData.Direction.BOTTOM, CellData.Direction.LEFT, CellData.Direction.TOP]
var directions_diagonal : Array[CellData.Direction] = [CellData.Direction.TOP_RIGHT, CellData.Direction.TOP_LEFT, CellData.Direction.BOTTOM_RIGHT, CellData.Direction.BOTTOM_LEFT]

var growth_options_used : Array[GrowthOption] = []
var max_empty_cell_ratio := 0.33
var num_perfect_numbers := 0

func generate() -> void:
	PuzzleSettings.apply_difficulty_properties(self)
	
	var num_tries := 0
	var max_tries := 100
	while true:
		print("PuzzleGenerator | Attempt ", num_tries)
		num_tries += 1
		
		create_grid()
		take_turns()
		var success := clean_up(num_tries > max_tries)
		if success: break

func create_grid() -> void:
	# first create the regular grid
	var grid_size := Vector2i(randi_range(num_lanes_bounds.x, num_lanes_bounds.y), randi_range(lane_length_bounds.x, lane_length_bounds.y))
	grid = PuzzleGrid.new()
	grid.neighbor_mode = PuzzleGrid.NeighborMode.ALL
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
	growth_options_used = []
	num_perfect_numbers = 0
	
	var directions : Array[CellData.Direction] = directions_orthogonal.duplicate(false)
	if allow_diagonals: directions += directions_diagonal
	
	var num_turns := randi_range(num_turns_bounds.x, num_turns_bounds.y)
	var try_another_growth_index := -1
	while solution.size() < num_turns:
		var valid_turns := get_all_valid_turns()
		if valid_turns.size() <= 0: break
		
		var rand_index := randi() % mini(valid_turns.size(), 3)
		var rand_cell := valid_turns[rand_index]
		
		# if a cell could not grow, we keep trying all the other valid cells,
		# and only break definitively if we've exhausted all options
		if try_another_growth_index >= 0:
			if try_another_growth_index >= valid_turns.size(): break
			rand_cell = valid_turns[try_another_growth_index]
		
		# decide if this should be a perfect hit; ensure it is if it's the last turn and we still don't have one
		var last_turn := solution.size() == (num_turns - 1)
		var make_perfect_number := ball_matches_pincount_remove_all and (randf() <= perfect_number_probability or (last_turn and num_perfect_numbers <= 0))
		if make_perfect_number: num_perfect_numbers += 1
		
		# find all options for "growing" the cell/puzzle ...
		var growth_options : Array[GrowthOption] = []
		for dir in directions:
			# if the ball is perfect, it will remove ALL upon hit, so EVERY direction is marked as an option for a pin
			if make_perfect_number:
				var new_option_0 := GrowthOption.new(GrowthOption.Type.PLACE, rand_cell, dir)
				growth_options.append(new_option_0)
				continue
			
			# if at the edge, we can always place a pin there (it would be removed if hit with ball)
			# @NOTE: this check ensures the nb_opposite EXISTS (because it only continues if the cell+dir we're discussing is NOT at the edge)
			if pin_is_at_edge(rand_cell, dir):
				var new_option_1 := GrowthOption.new(GrowthOption.Type.PLACE, rand_cell, dir)
				growth_options.append(new_option_1)
				continue
			
			# if there's a pin on the opposite side, we can attract it to our position
			var nb_opposite := rand_cell.get_opposite_neighbor(dir)
			var pin_opposite := nb_opposite.get_pin_at(dir)
			if pin_opposite != CellData.PinType.NONE:
				var new_option_2 := GrowthOption.new(GrowthOption.Type.ATTRACT, rand_cell, dir, nb_opposite, dir)
				growth_options.append(new_option_2)
				continue
			
			# otherwise, it means we are empty, the other side is empty, so we can place a pin on BOTH locations
			var double_placement_allowed := dir != CellData.Direction.BOTTOM and remove_pins_if_already_occupied
			if double_placement_allowed:
				var new_option_3 := GrowthOption.new(GrowthOption.Type.PLACE, rand_cell, dir, nb_opposite, dir)
				growth_options.append(new_option_3)
		
		var can_grow := growth_options.size() > 0
		if not can_grow:
			try_another_growth_index += 1
			continue
		
		try_another_growth_index = -1
		
		# ... then apply a random set of them
		var max_options := mini(growth_options.size(), max_grow_options_applied)
		var num_options_to_pick := randi_range(1, max_options)
		growth_options.shuffle()
		growth_options.sort_custom(func(a:GrowthOption, b:GrowthOption):
			if (not a.is_attraction()) and b.is_attraction(): return false
			return true
		)
		
		var options := growth_options.slice(0, num_options_to_pick)
		growth_options_used += options
		for option in options:
			option.apply()
		
		# and finally remember what we did
		var num_pins := rand_cell.count()
		var ball_number := get_random_ball_number(num_pins)
		if make_perfect_number:
			ball_number = num_pins
		
		var cur_lane := lanes[rand_cell.pos.x]
		var cmd := CommandTurn.new(cur_lane.index, ball_number, self)
		solution.append(cmd)
	
	# don't forget that we generated backward and need to reverse the solution!
	solution.reverse()

func get_random_ball_number(num_pins:int) -> int:
	if ball_too_weak_does_nothing:
		return num_pins + randi_range(1,3)
	
	var arr : Array[int] = [0,1,2,3,4,5,6,7,8]
	arr.erase(num_pins)
	return arr.pick_random()

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
	# that is, they must be in FRONT OF cells that already have pins
	# (which by default means all these cells are EMPTY right now)
	for lane in lanes:
		arr += lane.get_cells_before_first_non_empty()
	
	# then, we prefer cells with neighbors that have pins (for maximum interaction)
	# first, cache this calculation to prevent doing it over and over, then sort by it
	for elem in arr:
		elem.calculate_neighbor_pins()
		elem.calculate_lane_stats(lanes)
	
	arr.shuffle()
	arr.sort_custom(func(a:CellData, b:CellData): 
		# a should come AFTER b
		if (not a.lane_is_empty) and b.lane_is_empty: return false
		return a.neighbor_pins_pointed_at_us > b.neighbor_pins_pointed_at_us
	)
	
	return arr

func clean_up(desperate := false) -> bool:
	var num_turns_used := solution.size()
	if num_turns_used < num_turns_bounds.x:
		print("PuzzleGenerator | Discarded because too few turns.")
		return false
	
	var desired_perfect_number_hits := 1
	if ball_matches_pincount_remove_all and num_perfect_numbers < desired_perfect_number_hits:
		print("PuzzleGenerator | Discarded because too few perfect (ball) number hits used.")
		return false
	
	# the checks below are "nice-to-haves" but not required
	# so if simulation can't find anything for a while, ignore them
	if desperate: return true
	
	var num_attracts := growth_options_used.filter(func(go:GrowthOption): return go.type == GrowthOption.Type.ATTRACT).size()
	var num_attracts_desired := 2 if allow_diagonals else 1
	if num_attracts < num_attracts_desired:
		print("PuzzleGenerator | Discarded because too few attracts / pin traveling.")
		return false
	
	var num_total_cells := grid.cells.size()
	var num_empty_cells := grid.get_cells().filter(func(c:CellData): return c.is_empty()).size()
	var empty_cell_ratio := num_empty_cells / float(num_total_cells)
	# if we don't have double pin growth, the map is likely to be very empty, so don't check this
	if empty_cell_ratio > max_empty_cell_ratio and remove_pins_if_already_occupied:
		print("PuzzleGenerator | Discarded because too many empty cells (no map diversity)")
		return false
	
	return true
