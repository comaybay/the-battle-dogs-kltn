extends Control

@export var title: String
@export_file("*.tscn") var go_back_scene_path


func _ready() -> void:
	%TitleLabel.text = title
	%GoBackButton.pressed.connect(_on_go_back_pressed)
	
func _on_go_back_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file(go_back_scene_path)
