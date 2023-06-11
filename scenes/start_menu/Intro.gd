extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("fade in")
	$SkipButton.pressed.connect(_on_skip)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_skip() -> void:
	$AnimationPlayer.play("fade out")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	
	
