@tool
extends Control

@export var title: String:
	set(val):
		title = val
		
		if Engine.is_editor_hint():
			%TitleLabel.text = title
		
@export_file("*.tscn") var go_back_scene_path

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	%TitleLabel.text = title
	%GoBackButton.pressed.connect(_on_go_back_pressed)
	%Money.text = tr("@BONE") + ": %s" % Data.bone
	%DogFoodLabel.text = tr("@DOG_FOOD") + ": %s" % Data.dog_food
	#TODO: Dog food changed
	Data.bone_changed.connect(_on_bone_changed)
	
func _on_bone_changed(value: int):
	%Money.text = tr("@BONE") + ": %s" % value
	
func _on_go_back_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file(go_back_scene_path)

