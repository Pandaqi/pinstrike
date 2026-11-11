extends Node2D
class_name Ball

@export var visuals : Node2D
@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer
@export var label : Label

@export var audio_roll : AudioStreamPlayer2D
@export var audio_perfect_hit : AudioStreamPlayer2D
@export var audio_invalid_hit : AudioStreamPlayer2D
@export var audio_narrate : AudioStreamPlayer

@export var particles_move : CPUParticles2D

@export var ui := true

var rolling := false
var roll_hits_something := false
var roll_speed := 1000.0
var anim_speed := 2.0

var number := 1

var size : Vector2
var size_base := 128.0

signal roll_started()
signal roll_finished()

static func get_audio_for_number(num:int) -> AudioStream:
	return load("res://map/sounds/numbers/" + str(num) + ".mp3")

func _ready() -> void:
	label.hide()
	particles_move.set_emitting(false)
	audio_narrate.bus = "UI"
	if not ui: hide()

func roll_over_lane(lane:Lane) -> void:
	var cell := lane.data.get_first_cell_hit()
	roll_hits_something = cell != null
	var pos_start := lane.get_start_position()
	var pos_end := lane.get_position_of(cell)
	roll(pos_start, pos_end)

func roll(pos_start:Vector2, pos_end:Vector2) -> void:
	roll_started.emit()
	
	show()
	anim_player.speed_scale = anim_speed
	anim_player.play("roll")
	rolling = true
	
	label.hide()
	
	PuzzleAudio.play_audio_nice(audio_roll)

	var dist := pos_start.distance_to(pos_end)
	var dur := dist / roll_speed
	
	set_position(pos_start)
	particles_move.set_emitting(true)
	
	var tw := get_tree().create_tween()
	tw.tween_property(self, "position", pos_end, dur)
	tw.tween_callback(_on_roll_finished)

func _on_roll_finished() -> void:
	rolling = false
	anim_player.stop()
	hide()
	
	label.show()
	
	particles_move.set_emitting(false)
	particles_move.restart()
	
	audio_roll.stop()

	roll_finished.emit()

func set_size(new_size:Vector2) -> void:
	size = new_size
	visuals.set_scale(new_size / size_base)

func set_number(num:int) -> void:
	number = num
	label.set_text(str(num))
	if not PuzzleVisualizer.show_number_on_balls(): return
	label.show()

func highlight() -> void:
	PuzzleTween.play_popup_tween(self)
	modulate.a = 1.0
	anim_player.play("roll")
	
	if PuzzleSettings.get_value("narrate_numbers") and PuzzleVisualizer.show_number_on_balls():
		audio_narrate.stream = get_audio_for_number(number)
		audio_narrate.play()

func unhighlight() -> void:
	set_scale(Vector2.ONE * 0.8)
	modulate.a = 0.66
	anim_player.stop()

func play_perfect_hit_sound() -> void:
	PuzzleAudio.play_audio_nice(audio_perfect_hit)

func play_invalid_hit_sound(reason := "low-number") -> void:
	var txt := "Number Too Low!" if reason == "low-number" else "Occupied!"
	PuzzleTween.give_feedback(get_parent(), global_position, txt)
	PuzzleAudio.play_audio_nice(audio_invalid_hit)
