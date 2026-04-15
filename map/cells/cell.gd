extends Node2D
class_name Cell

var data : CellData

@export var sprite : Sprite2D
@export var pin_container : Node2D
@export var pin_scene : PackedScene
var pins : Array[Pin] = []
var pin_offset := 32.0

func _ready() -> void:
	create_pins()

func create_pins() -> void:
	for i in range(8):
		var pin : Pin = pin_scene.instantiate()
		pins.append(pin)
		add_child(pin)

func sync_to_data(dt:CellData) -> void:
	data = dt
	data.changed.connect(_on_data_changed)
	_on_data_changed()

func _on_data_changed() -> void:
	for pin in pins:
		pin.hide()
	
	var counter := 0
	for dir in data.pins_by_direction:
		var tp := data.pins_by_direction[dir]
		if tp == CellData.PinType.NONE: continue
		
		var pin := pins[counter]
		counter += 1
		pin.show()
		pin.set_position(CellData.convert_direction_to_vector(dir) * pin_offset)



# LALA STOP FUCKING REMOVING MY WHITESPACE AT THE BOTTOM GODOT!
