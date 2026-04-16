extends PuzzleCell
class_name CellData

enum Direction
{
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM,
	BOTTOM_LEFT,
	LEFT,
	TOP_LEFT,
	TOP,
	TOP_RIGHT
}

enum PinType
{
	NONE,
	REGULAR
}

var pins : Array[PinType] = []
var pins_by_direction : Dictionary[Direction,PinType] = {}
var neighbors_by_direction : Dictionary[Direction, CellData] = {}

static var vector_to_direction : Dictionary[String,Direction] = {
	"10": Direction.RIGHT,
	"11": Direction.BOTTOM_RIGHT,
	"01": Direction.BOTTOM,
	"-11": Direction.BOTTOM_LEFT,
	"-10": Direction.LEFT,
	"-1-1": Direction.TOP_LEFT,
	"0-1": Direction.TOP,
	"1-1": Direction.TOP_RIGHT
}

static var direction_to_vector : Dictionary[Direction,Vector2i] = {
	Direction.RIGHT: Vector2i.RIGHT,
	Direction.BOTTOM_RIGHT: Vector2i(1,1),
	Direction.BOTTOM: Vector2i.DOWN,
	Direction.BOTTOM_LEFT: Vector2i(-1,1),
	Direction.LEFT: Vector2i.LEFT,
	Direction.TOP_LEFT: Vector2i(-1,-1),
	Direction.TOP: Vector2i.UP,
	Direction.TOP_RIGHT: Vector2i(1,-1)
}

var neighbor_pins_pointed_at_us := 0
var lane_is_empty := false

func has_pin_at(dir:Direction) -> bool:
	return get_pin_at(dir) != PinType.NONE

func get_pin_at(dir:Direction) -> PinType:
	if not (dir in pins_by_direction): return PinType.NONE
	return pins_by_direction[dir]

func add_pin(tp:PinType, dir:Direction) -> void:
	pins.append(tp)
	pins_by_direction[dir] = tp
	changed.emit()

func remove_pin(dir:Direction) -> void:
	var tp := pins_by_direction[dir]
	pins_by_direction[dir] = PinType.NONE
	pins.erase(tp)
	changed.emit()

func count() -> int:
	return pins.size()

func is_empty() -> bool:
	return count() <= 0

static func convert_vector_to_direction(vec:Vector2i) -> Direction:
	return vector_to_direction[str(vec.x) + str(vec.y)]

static func convert_direction_to_vector(dir:Direction) -> Vector2i:
	return direction_to_vector[dir]

static func get_dir_opposite_to(dir:Direction) -> Direction:
	return convert_vector_to_direction( -1 * convert_direction_to_vector(dir) )

func get_opposite_neighbor(dir:Direction) -> CellData:
	if not dir in neighbors_by_direction: return null
	return neighbors_by_direction[dir]

func get_pin_on_opposite_neighbor(dir:Direction) -> PinType:
	var nb := get_opposite_neighbor(dir)
	if not nb: return PinType.NONE
	return nb.get_pin_at(dir)

func calculate_neighbor_data() -> void:
	neighbors_by_direction = {}
	for nb in neighbors:
		var vec_to_them := nb.pos - pos
		var nb_dir := convert_vector_to_direction(vec_to_them)
		neighbors_by_direction[nb_dir] = nb as CellData

func calculate_neighbor_pins() -> void:
	var sum := 0
	for dir in neighbors_by_direction:
		if get_pin_on_opposite_neighbor(dir) == PinType.NONE: continue
		sum += 1
	neighbor_pins_pointed_at_us = sum

# @TODO: could cache the is_empty() call on LaneData first to prevent recalculating all the time
func calculate_lane_stats(lanes:Array[LaneData]) -> void:
	lane_is_empty = lanes[pos.x].is_empty()
	
