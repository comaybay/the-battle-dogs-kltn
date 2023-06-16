extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SkipButton.pressed.connect(_on_skip, CONNECT_ONE_SHOT)
	$AnimationPlayerText.animation_finished.connect(_on_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_skip() -> void:
	$AnimationPlayer.pause()
	_on_finished()
	
func _on_finished() -> void:
	$ColorRect.visible = true
	var tween = create_tween()
	tween.tween_property($ColorRect, "color:a8", 255, 1.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	
