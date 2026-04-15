class_name GrowthOption

enum Type
{
	PLACE,
	ATTRACT
}

var type : Type
var cell_1 : CellData
var dir_1 : CellData.Direction
var cell_2 : CellData
var dir_2 : CellData.Direction

func _init(tp:Type, c1:CellData, d1:CellData.Direction, c2:CellData = null, d2 := CellData.Direction.RIGHT):
	type = tp
	cell_1 = c1
	dir_1 = d1
	cell_2 = c2
	dir_2 = d2

func apply() -> void:
	if type == Type.ATTRACT:
		var pin_type := cell_2.get_pin_at(dir_2)
		cell_2.remove_pin(dir_2)
		cell_1.add_pin(pin_type, dir_1)
	
	# @TODO: How to allow selecting from range of options for PinTypes available in this puzzle?
	if type == Type.PLACE:
		cell_1.add_pin(CellData.PinType.REGULAR, dir_1)
		if cell_2 and dir_2:
			cell_2.add_pin(CellData.PinType.REGULAR, dir_2)
