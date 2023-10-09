@tool
extends Control

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
		
	%TitleLabel.text = tr(%TitleLabel.text)
	%GoBackButton.pressed.connect(_on_go_back_pressed)
	%Money.text = str(Data.bone)
	%DogFoodLabel.text = tr("@DOG_FOOD") + ": %s" % Data.dog_food
	#TODO: Dog food changed
	Data.bone_changed.connect(_on_bone_changed)
	
	Data.select_data.connect(show_select_data_box)

func show_select_data_box():	
	$Khung/Content/ConfirmationDialog.show()	
	

func _on_bone_changed(value: int):
	%Money.text = str(Data.bone)
	
func _on_go_back_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file(go_back_scene_path)

func _on_confirmation_dialog_player():
	Data.old_data = Data.silentwolf_data
	Data.save_data= Data.silentwolf_data

func _on_confirmation_dialog_computer():	
	SilentWolf.Players.save_player_data(Steam.getPersonaName(), Data.save_data)
	
