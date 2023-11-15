@tool
class_name MainGUI extends Control

@export var title: String:
	set(val):
		title = val
		notify_property_list_changed()
		
@export_file("*.tscn") var go_back_scene_path

func _ready() -> void:
	if Engine.is_editor_hint():
		property_list_changed.connect(func(): 
			%TitleLabel.text = title
		)
		return
		
	%TitleLabel.text = "%s - %s" % [tr("@DOG_BASE"), tr("@LOCATION_%s" % Data.selected_chapter_id)]
	%GoBackButton.pressed.connect(_on_go_back_pressed)
	%Money.text = str(Data.bone)
#	%DogFoodLabel.text = tr("@DOG_FOOD") + ": %s" % Data.dog_food
	#TODO: Dog food changed
	Data.bone_changed.connect(_on_bone_changed)

func _on_bone_changed(value: int):
	%Money.text = str(Data.bone)
	
func _on_go_back_pressed():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file(go_back_scene_path)

func get_go_back_button() -> Button:
	return %GoBackButton
