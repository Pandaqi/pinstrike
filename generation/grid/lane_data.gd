class_name LaneData

var index : int
var cells : Array[CellData] = []

signal changed() # @TODO: not used right now

func _init(idx:int, cls:Array[CellData]):
	index = idx
	cells = cls

func count_pins() -> int:
	var sum := 0
	for cell in cells:
		sum += cell.count()
	return sum

func is_empty() -> bool:
	return count_pins() <= 0

func get_first_cell_hit() -> CellData:
	var idx_first := get_non_empty_indices().first
	if idx_first == -1: return null
	return cells[idx_first]

func get_non_empty_indices() -> Dictionary[String, int]:
	# The lanes are laid out with Y increasing as you go downwards
	# But our bowling ball throws start at the BOTTOM
	# So, "first" is actually the highest number = lowest Y coordinate
	var last_non_empty := -1
	var first_non_empty := -1
	for i in range(cells.size()):
		var cell := cells[i]
		if cell.is_empty(): continue
		first_non_empty = i
		if last_non_empty == -1:
			last_non_empty = i
	
	return { "first": first_non_empty, "last": last_non_empty }

func get_cells_before_first_non_empty() -> Array[CellData]:
	var idxs := get_non_empty_indices()
	var min_index := idxs.first + 1
	
	# @NOTE: this is EXCLUSIVE in the slice()
	# We prefer picking cells as far back as possible; so at most 3 spaces in front of first index; otherwise generation might pick the front-most cell and now that entire lane can't change in any way during generation ...
	var max_index := mini(cells.size(), min_index + 3) 
	return cells.slice(min_index, max_index)
