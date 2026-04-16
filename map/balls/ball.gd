extends Node2D
class_name Ball

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer

var rolling := false
var roll_speed := 900.0
var anim_speed := 2.0

signal roll_started()
signal roll_finished()

func _ready() -> void:
	hide()

func roll(lane:Lane) -> void:
	roll_started.emit()
	
	show()
	anim_player.speed_scale = anim_speed
	anim_player.play("roll")
	rolling = true

	var cell := lane.data.get_first_cell_hit()
	
	var pos_start := lane.get_start_position()
	var pos_end := lane.get_position_of(cell)
	var dist := pos_start.distance_to(pos_end)
	var dur := dist / roll_speed
	
	set_position(pos_start)
	
	var tw := get_tree().create_tween()
	tw.tween_property(self, "position", pos_end, dur)
	tw.tween_callback(_on_roll_finished)

func _on_roll_finished() -> void:
	rolling = false
	anim_player.stop()
	hide()
	
	roll_finished.emit()

	
