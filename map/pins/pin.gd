extends Node2D
class_name Pin

@export var sprite : Sprite2D
@export var anim_player : AnimationPlayer

func reset() -> void:
	hide()
	anim_player.play("default")

func play_appear_animation() -> void:
	show()
	anim_player.play("reveal")

func play_disappear_animation() -> void:
	show()
	anim_player.play_backwards("reveal")
