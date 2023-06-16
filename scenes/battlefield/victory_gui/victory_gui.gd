extends CanvasLayer

@onready var bone_label = $Control/Panel/HBoxContainer/BoneLabel
@onready var return_button = $Control/Panel/Button 

func _ready() -> void:
	return_button.pressed.connect(_go_to_dog_base)
	$AnimationPlayer.play("default")
	var tween = create_tween()
	
	var reward_bone: int = InBattle.battlefield_data['reward_bone']
	
	var reward_upgrade: Dictionary = Data.passives['bone_reward_up']
	if reward_upgrade != null:
		reward_bone = reward_bone + (reward_bone * 0.2 * reward_upgrade['level'])
	
	tween.tween_method(_tween_bone_number, 0, reward_bone, 1).set_delay(1)
	
	Data.passed_level = max(Data.passed_level, Data.selected_level)
	Data.bone += reward_bone
	Data.save()

func _tween_bone_number(value: int):
	bone_label.text = str(value)

func _go_to_dog_base():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")
