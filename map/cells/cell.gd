extends Node2D
class_name Cell

var data : CellData

@export var sprite : Sprite2D
@export var pin_container : Node2D
@export var pin_scene : PackedScene
var pins : Array[Pin] = []
var pin_offset := 84.0
var pins_old : Dictionary[CellData.Direction, CellData.PinType] = {}

func _ready() -> void:
	create_pins()

func on_appear() -> void:
	for pin in pins:
		pin.play_appear_animation()

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
	var all_directions := CellData.get_all_directions()
	for dir in all_directions:
		var pin := pins[dir] # because direction is an enum 0,1,2,etc. we can do this
		
		var type_old : CellData.PinType = pins_old.get(dir, CellData.PinType.NONE)
		var type_new : CellData.PinType = data.pins_by_direction.get(dir, CellData.PinType.NONE)
		var is_change := type_new != type_old
		
		if type_new == CellData.PinType.NONE: 
			pin.hide()
			#if is_change: pin.play_disappear_animation()
			continue
		
		#if is_change: pin.play_appear_animation()
		pin.show()
		pin.z_index = 3 + CellData.convert_direction_to_vector(dir).y
		pin.set_type(type_new)
		pin.set_direction(dir)
		pin.set_position(to_local(get_position_of_pin_at(dir)))
	
	pins_old = data.pins_by_direction.duplicate(false)

func get_pin_at(dir:CellData.Direction) -> Pin:
	return pins[dir]

func get_position_of_pin_at(dir:CellData.Direction) -> Vector2:
	return global_position + CellData.convert_direction_to_vector(dir) * pin_offset



# LALA STOP FUCKING REMOVING MY WHITESPACE AT THE BOTTOM GODOT!
