extends Control

@export var title: String
@export_file("*.tscn") var go_back_scene_path


func _ready() -> void:
	%TitleLabel.text = title
	%GoBackButton.pressed.connect(_on_go_back_pressed)
	%Money.text = "Xương: %s" % Data.bone
	Data.bone_changed.connect(_on_bone_changed)
	
func _on_bone_changed(value: int):
	%Money.text = "Xương: %s" % value
	
func _on_go_back_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file(go_back_scene_path)


	

