class_name HitFx extends Node2D

func _ready() -> void:
	rotation_degrees = randi_range(0, 360)
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(func(): queue_free())


