extends CanvasLayer

@onready var bone_label = $Control/Panel/HBoxContainer/BoneLabel
@onready var return_button = $Control/Panel/Button 

func _ready() -> void:	
	var battlefield = get_tree().current_scene as Battlefield
	var battlefield_data = battlefield.get_battlefield_data()
	
	$AnimationPlayer.play("default")
	var tween = create_tween()
	
	var reward_bone: int = battlefield_data['reward_bone']
	
	var reward_upgrade = Data.passives.get('bone_reward_up')
	if reward_upgrade != null:
		reward_bone = reward_bone + (reward_bone * 0.1 * reward_upgrade['level'])
	
	tween.tween_method(_tween_bone_number, 0, reward_bone, 2).set_delay(1)
	
	Data.passed_stage = max(Data.passed_stage, Data.selected_stage)
	if Data.passed_stage >= Data.chapter_last_stage:
		Data.save_data['chapters'][Data.selected_chapter_id]['completed'] = true
		return_button.pressed.connect(_go_to_ending)
	else:
		return_button.pressed.connect(_go_to_dog_base)
	
	Data.bone += reward_bone
	Data.save()

func _tween_bone_number(value: int):
	bone_label.text = str(value)

func _go_to_dog_base():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func _go_to_ending():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	var ending_id = Data.selected_chapter_id + "_ending"
	get_tree().change_scene_to_file("res://scenes/endings/%s/%s.tscn" % [ending_id, ending_id])
