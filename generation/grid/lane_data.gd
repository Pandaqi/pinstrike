class_name LaneData

var index : int
var cells : Array[CellData] = []
var cells_struck : Array[int] = []

func _init(idx:int, cls:Array[CellData]):
	index = idx
	cells = cls

func strike_cell(c:CellData) -> void:
	cells_struck.append(cells.find(c))

# The lanes are laid out with Y increasing as you go downwards
# But our bowling ball throws start at the BOTTOM
# So, "first" is actually the highest number = lowest Y coordinate
func get_first_struck() -> int:
	cells_struck.sort()
	return cells_struck.back()

func get_last_struck() -> int:
	cells_struck.sort()
	return cells_struck.front()

func count_cells_struck() -> int:
	return cells_struck.size()

func get_cells_before_first_struck() -> Array[CellData]:
	if count_cells_struck() <= 0: return cells.duplicate(false)
	var first_struck := get_first_struck()
	return cells.slice(first_struck, cells.size())
