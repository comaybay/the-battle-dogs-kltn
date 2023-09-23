extends Panel

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(
		func(_anim): get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	)
