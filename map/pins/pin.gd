extends Node2D
class_name Pin

@export var visuals : Node2D
@export var sprite : Sprite2D
@export var sprite_shadow : Sprite2D
@export var anim_player : AnimationPlayer
@export var squasher_stretcher : SquasherStretcher

@export var audio_knock : AudioStreamPlayer2D
@export var audio_narrate : AudioStreamPlayer

@export var particles_move : CPUParticles2D

@export var floating := false

var type : CellData.PinType
var direction : CellData.Direction

signal animation_finished()

func _ready() -> void:
	particles_move.set_emitting(false)
	anim_player.animation_finished.connect(func(_anim_name): animation_finished.emit())
	audio_narrate.bus = "UI"
	if floating: 
		squasher_stretcher.set_paused(true)
		sprite_shadow.hide()

func reset() -> void:
	hide()
	anim_player.play("default")

func play_appear_animation(speed_mult := 1.0) -> void:
	particles_move.restart()
	particles_move.set_emitting(true)
	anim_player.speed_scale = randf_range(0.8, 1.2) * speed_mult
	anim_player.play("reveal")

func play_disappear_animation(speed_mult := 1.0) -> void:
	particles_move.restart()
	particles_move.set_emitting(true)
	anim_player.speed_scale = randf_range(0.8, 1.2) * speed_mult
	anim_player.play_backwards("reveal")

func play_knock_sound(dir:CellData.Direction) -> void:
	particles_move.restart()
	particles_move.set_emitting(true)
	if PuzzleSettings.get_value("narrate_directions"):
		audio_narrate.stream = CellData.get_audio_for_direction(dir)
		audio_narrate.play()
	PuzzleAudio.play_audio_nice(audio_knock)

# @TODO: This will be useful if I ever want more than 1 PinType
func set_type(tp:CellData.PinType) -> void:
	type = tp
	sprite.set_frame(tp - 1)

func set_direction(dir:CellData.Direction) -> void:
	direction = dir
	if PuzzleSettings.get_value("color_by_direction"):
		visuals.modulate = CellData.get_color_for_direction(direction)

func match_look_of(pin:Pin) -> void:
	set_type(pin.type)
	set_direction(pin.direction)
