extends CanvasLayer

func _ready() -> void:
	$Panel/Panel/CloseButton.pressed.connect(_on_close_menu)
	$Panel/Panel/EscapeBattleButton.pressed.connect(_on_escape_battle)
	$Panel/Panel/ToMainMenuButton.pressed.connect(_on_to_main_menu)
	
func _on_close_menu() -> void:
	get_tree().paused = false
	hide()
	
func _on_escape_battle() -> void:
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")
	
func _on_to_main_menu() -> void:
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")

func _exit_tree() -> void:
	get_tree().paused = false
	
