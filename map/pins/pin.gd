extends Node2D
class_name Pin

@export var visuals : Node2D
@export var sprite : Sprite2D
@export var sprite_shadow : Sprite2D
@export var anim_player : AnimationPlayer
@export var squasher_stretcher : SquasherStretcher
@export var floating := false

signal animation_finished()

func _ready() -> void:
	anim_player.animation_finished.connect(func(_anim_name): animation_finished.emit())
	if floating: 
		squasher_stretcher.set_paused(true)
		sprite_shadow.hide()

func reset() -> void:
	hide()
	anim_player.play("default")

func play_appear_animation(speed_mult := 1.0) -> void:
	anim_player.speed_scale = randf_range(0.8, 1.2) * speed_mult
	anim_player.play("reveal")

func play_disappear_animation(speed_mult := 1.0) -> void:
	anim_player.speed_scale = randf_range(0.8, 1.2) * speed_mult
	anim_player.play_backwards("reveal")
