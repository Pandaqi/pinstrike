extends Node2D
class_name Ball

@export var visuals : Node2D
@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer
@export var label : Label

@export var ui := true

var rolling := false
var roll_speed := 1000.0
var anim_speed := 2.0

var size : Vector2
var size_base := 128.0

signal roll_started()
signal roll_finished()

func _ready() -> void:
	label.hide()
	if not ui: hide()

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

func set_size(new_size:Vector2) -> void:
	size = new_size
	visuals.set_scale(new_size / size_base)

func set_number(num:int) -> void:
	if not PuzzleVisualizer.show_number_on_balls(): return
	label.show()
	label.set_text(str(num))

func highlight() -> void:
	PuzzleTween.play_popup_tween(self)
	modulate.a = 1.0
	anim_player.play("roll")

func unhighlight() -> void:
	set_scale(Vector2.ONE * 0.8)
	modulate.a = 0.66
	anim_player.stop()
